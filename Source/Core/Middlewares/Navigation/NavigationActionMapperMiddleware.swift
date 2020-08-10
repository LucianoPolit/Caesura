//
//  NavigationActionMapperMiddleware.swift
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

class NavigationActionMapperMiddleware: ActionMapperMiddleware {
    
    override func handle(
        action: Action,
        next: @escaping DispatchFunction,
        dispatch: @escaping DispatchFunction
    ) {
        let startAction: Action? = {
            guard case ApplicationCompletionAction.didFinishLaunching = action else { return nil }
            return NavigationAction.start
        }()
        super.handle(
            action: startAction ?? action,
            next: next,
            dispatch: dispatch
        )
        if case ApplicationCompletionAction.didFinishLaunching = action { next(action) }
    }
    
}
