//
//  APIActionDispatcher+Common.swift
//  Common
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import Leash

extension APIActionDispatcher {
    
    public func handle<U>(
        request: (@escaping (Response<U>) -> Void) -> Void,
        loading: ActionType,
        success: @escaping (U) -> ActionType,
        failure: @escaping (Error) -> ActionType,
        destination: @escaping Destination
    ) {
        handle(
            request: { completion in
                request { response in
                    completion(
                        response.justValue()
                    )
                }
            },
            loading: loading,
            success: success,
            failure: { error in
                failure(
                    error.toValidError()
                )
            },
            destination: destination
        )
    }
    
    public func handle<U, V>(
        request: (@escaping (Response<V>) -> Void) -> Void,
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
