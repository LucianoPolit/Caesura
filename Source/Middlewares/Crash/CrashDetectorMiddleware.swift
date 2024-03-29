//
//  CrashDetectorMiddleware.swift
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

public enum CrashDetectorCompletionAction: Action {
    case willCrash
    case didCrash
}

public class CrashDetectorMiddleware: Middleware {
    
    private static let key = "CrashDetectorMiddlewareKey"
    private static var didCrashLastTime: Bool {
        get {
            return UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    public init() { }
    
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

private extension CrashDetectorMiddleware {
    
    func handle(
        action: Action,
        next: @escaping DispatchFunction,
        dispatch: @escaping DispatchFunction
    ) {
        guard case ApplicationCompletionAction.didFinishLaunching = action else { return }
        
        CrashDetector.start {
            CrashDetectorMiddleware.didCrashLastTime = true
            dispatch(CrashDetectorCompletionAction.willCrash)
        }
        
        guard CrashDetectorMiddleware.didCrashLastTime else { return }
        CrashDetectorMiddleware.didCrashLastTime = false
        dispatch(CrashDetectorCompletionAction.didCrash)
    }
    
}
