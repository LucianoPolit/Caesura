//
//  Endpoint.swift
//  API
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

protocol Endpoint: Leash.Endpoint {
    var basePath: String { get }
    var pathParameters: [String: CustomStringConvertible]? { get }
}

extension Endpoint {
    
    var path: String {
        guard let parameters = pathParameters else {
            return basePath
        }
        
        var finalPath = basePath
        
        for (parameter, value) in parameters {
            finalPath = finalPath.replacingOccurrences(of: parameter, with: "\(value)")
        }
        
        return finalPath
    }
    
    var pathParameters: [String: CustomStringConvertible]? {
        return nil
    }
    
}
