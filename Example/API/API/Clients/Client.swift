//
//  Client.swift
//  API
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

protocol Targetable {
    associatedtype Target: Endpoint
}

extension Targetable where Self: Client {
    
    @discardableResult
    func execute<T: Decodable>(
        _ endpoint: Target,
        completion: @escaping (Response<T>) -> Void
    ) -> DataRequest? {
        return execute(
            endpoint as Leash.Endpoint,
            completion: completion
        )
    }
    
}
