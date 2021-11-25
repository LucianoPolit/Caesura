//
//  ActionBlocklistMiddleware.swift
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
#endif

public enum ActionBlocklistAction: Action {
    case enable
    case disable
    case addToBlocklist(Action.Type)
    case removeFromBlocklist(Action.Type)
}

public class ActionBlocklistMiddleware: DebugMiddleware {
    
    private var isEnabled = false
    private var blocklist: [Action.Type] = []
    
    public init() { }
    
    public func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.handle(
                    action: action,
                    next: next
                )
            }
        }
    }
    
}

private extension ActionBlocklistMiddleware {
    
    func handle(
        action: Action,
        next: DispatchFunction
    ) {
        if let blockerAction = action as? ActionBlocklistAction {
            switch blockerAction {
            case .enable: isEnabled = true
            case .disable: isEnabled = false
            case .addToBlocklist(let type): blocklist.append(type)
            case .removeFromBlocklist(let type):
                guard let index = blocklist.firstIndex(where: { $0 == type }) else { return }
                blocklist.remove(at: index)
            }
            return
        }
        
        guard !isEnabled || !blocklist.contains(where: { $0 == type(of: action) }) else { return }
        next(action)
    }
    
}
