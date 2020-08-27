//
//  MockClient.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

extension Client {
    
    func handleCall<T>(
        _ endpoint: MockEndpoint<T>,
        parameters: Any,
        completion: @escaping (Response<T>) -> Void
    ) {
        endpoint.spy.addCall(
            APICall(
                parameters: parameters
            )
        )
        
        if endpoint.success {
            completion(
                .success(
                    value: endpoint.successResponse,
                    extra: nil
                )
            )
        } else {
            completion(
                .failure(
                    endpoint.failureResponse
                )
            )
        }
    }
    
}
