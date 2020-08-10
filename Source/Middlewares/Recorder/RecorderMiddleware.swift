//
//  RecorderMiddleware.swift
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

public class RecorderMiddleware: Middleware {
    
    public let store: StandardActionStore
    private var actionsAndKeys: [(StandardAction, String, Date)] = []
    
    private var backgroundCalled = false
    private var foregroundCalled = false
    
    public init(
        store: StandardActionStore = .default
    ) {
        self.store = store
    }
    
    public func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.handle(
                    action: action
                )
                next(action)
            }
        }
    }
    
}

private extension RecorderMiddleware {
    
    func handle(
        action: Action
    ) {
        if let convertible = action as? StandardActionConvertible,
            let action = convertible.toStandard() {
            actionsAndKeys.append(
                (
                    action,
                    convertible.key,
                    Date()
                )
            )
        }
        
        switch action {
        case ApplicationCompletionAction.didEnterBackground,
             ApplicationCompletionAction.willTerminate,
             CrashDetectorCompletionAction.willCrash:
            if backgroundCalled || foregroundCalled {
                try? store.eraseLastSaving()
                backgroundCalled = false
                foregroundCalled = false
            }
            try? store.save(actionsAndKeys)
        default: break
        }
        
        switch action {
        case ApplicationCompletionAction.didEnterBackground:
            backgroundCalled = true
        case ApplicationCompletionAction.willEnterForeground:
            guard backgroundCalled else { break }
            foregroundCalled = true
        default: break
        }
    }
    
}

private extension StandardActionConvertible {
    
    var key: String {
        return Self.key
    }
    
}
