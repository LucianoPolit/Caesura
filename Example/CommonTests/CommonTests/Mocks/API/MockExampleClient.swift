//
//  MockExampleClient.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash
@testable import API

public class MockExampleClient: ExampleClient {
    
    public let readAllEndpoint = MockEndpoint(
        success: [
            String()
        ]
    )
    
    public override func readAll(
        completion: @escaping (Response<[String]>) -> Void
    ) {
        handleCall(
            readAllEndpoint,
            parameters: (),
            completion: completion
        )
    }
    
}
