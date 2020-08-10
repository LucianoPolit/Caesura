//
//  RetrieverMiddleware.swift
//
//  Copyright (c) 2020 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
#if !COCOAPODS
import Caesura
import StandardAction
#endif

public enum RetrieverCompletionAction: Action {
    case start
    case finish
}

public class RetrieverMiddleware: DebugMiddleware {
    
    public let store: StandardActionStore
    public let timeInterval: TimeInterval
    
    public init(
        store: StandardActionStore = .default,
        timeInterval: TimeInterval?
    ) {
        self.store = store
        self.timeInterval = timeInterval ?? 0.05
    }
    
    public func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.handle(
                    action: action,
                    next: next,
                    dispatch: dispatch
                )
                next(action)
            }
        }
    }
    
}

private extension RetrieverMiddleware {
    
    func handle(
        action: Action,
        next: @escaping DispatchFunction,
        dispatch: @escaping DispatchFunction
    ) {
        guard case ApplicationCompletionAction.didFinishLaunching = action,
            let actions = try? store.loadFromResources(),
            !actions.isEmpty
            else { return }
        
        let actionsToDispatch = { (bool: Bool) -> [Action] in
            var actions: [Action] = self.store.types
                .map(bool ? ActionBlacklistAction.addToBlacklist : ActionBlacklistAction.removeFromBlacklist)
            actions.append(bool ? ActionBlacklistAction.enable : ActionBlacklistAction.disable)
            actions.append(bool ? AnimationBlockerAction.enable : AnimationBlockerAction.disable)
            return actions
        }
        
        actionsToDispatch(true).forEach(dispatch)
        next(RetrieverCompletionAction.start)
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "RetrieverMiddlewareQueue")
        
        queue.asyncAfter(deadline: .now() + 1) {
            actions.forEach { action in
                DispatchQueue.main.async { next(action) }
                _ = semaphore.wait(timeout: .now() + self.timeInterval)
            }
            
            DispatchQueue.main.async {
                actionsToDispatch(false).forEach(dispatch)
                next(RetrieverCompletionAction.finish)
            }
        }
    }
    
}
