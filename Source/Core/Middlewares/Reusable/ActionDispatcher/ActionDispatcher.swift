//
//  ActionDispatcher.swift
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

public protocol ActionDispatcherProtocol: AnyObject {
    func dispatch(
        _ action: Action,
        to destination: @escaping DispatchFunction
    ) -> Bool
}

public protocol ActionDispatcher: ActionDispatcherProtocol {
    associatedtype ActionType: Action
    typealias Destination = (ActionType) -> Void
    func dispatch(
        _ action: ActionType,
        to destination: @escaping Destination
    ) -> Bool
}

extension ActionDispatcher {
    
    public func dispatch(
        _ action: Action,
        to destination: @escaping DispatchFunction
    ) -> Bool {
        guard let action = action as? ActionType else { return false }
        return dispatch(action as ActionType, to: destination as Destination)
    }
    
}
