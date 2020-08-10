//
//  ExampleClient.swift
//  API
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

public class ExampleClient: Client, Targetable {
    
    typealias Target = ExampleEndpoint
    
    public func readAll(
        completion: @escaping (Response<[String]>) -> Void
    ) {
        execute(
            .readAll,
            completion: completion
        )
    }
    
}
