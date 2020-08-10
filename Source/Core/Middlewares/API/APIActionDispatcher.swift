//
//  APIActionDispatcher.swift
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

open class APIActionDispatcher<ActionType: Action>: ActionDispatcher {
    
    public init() { }
    
    open func dispatch(
        _ action: ActionType,
        to destination: @escaping Destination
    ) -> Bool {
        return false
    }
    
}

extension APIActionDispatcher {
    
    public func handle<U>(
        request: (@escaping (Result<U, Error>) -> Void) -> Void,
        loading: ActionType,
        success: @escaping (U) -> ActionType,
        failure: @escaping (Error) -> ActionType,
        destination: @escaping Destination
    ) {
        destination(loading)
        request { response in
            switch response {
            case .success(let result):
                destination(
                    success(result)
                )
            case .failure(let error):
                destination(
                    failure(error)
                )
            }
        }
    }
    
    public func handle<U, V>(
        request: (@escaping (Result<V, Error>) -> Void) -> Void,
        loading: ActionType,
        success: @escaping (U) -> ActionType,
        failure: @escaping (Error) -> ActionType,
        mapSuccess: @escaping (V) -> U,
        mapFailure: @escaping (Error) -> Error = { $0 },
        destination: @escaping Destination
    ) {
        handle(
            request: request,
            loading: loading,
            success: { success(mapSuccess($0)) },
            failure: { failure(mapFailure($0)) },
            destination: destination
        )
    }
    
}
