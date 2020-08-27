//
//  MockEndpoint.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

public class MockEndpoint<T: Decodable> {
    
    public var spy = APISpy()
    public var successResponse: T
    public var failureResponse: Swift.Error
    public var success = true
    public var callResponse = true
    
    public init(
        success: T,
        error: Swift.Error = Error.unknown
    ) {
        successResponse = success
        failureResponse = error
    }
    
}

public struct APISpy {
    
    private(set) var calls: [APICall] = []
    
    public var called: Bool {
        return calls.count != 0
    }
    
    public var lastCall: APICall? {
        return calls.last
    }
    
    mutating func addCall(
        _ call: APICall
    ) {
        calls.append(call)
    }
    
}

public struct APICall {
    
    let parameters: Any
    
}
