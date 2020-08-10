//
//  ExampleEndpoint.swift
//  API
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

enum ExampleEndpoint: Endpoint {
    case readAll
}

extension ExampleEndpoint {
    
    var method: HTTPMethod {
        switch self {
        case .readAll: return .get
        }
    }
    
    var basePath: String {
        switch self {
        case .readAll: return "example"
        }
    }
    
    var pathParameters: [String: CustomStringConvertible]? {
        switch self {
        case .readAll: return nil
        }
    }
    
    var parameters: Any? {
        switch self {
        case .readAll: return nil
        }
    }
    
}
