//
//  Error.swift
//  Common
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation

public enum Error: String, Swift.Error, Codable {
    case unknown
}

extension Swift.Error {
    
    public func toValidError() -> Error {
        return .unknown
    }
    
}
