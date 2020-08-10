//
//  Manager.swift
//  API
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Leash

public class Manager {
    
    // MARK: - Domain
    
    static let scheme = "http"
    static let host = "localhost:3000"
    static let path = "api"
    
    // MARK: - Properties
    
    let manager: Leash.Manager
    
    // MARK: - Clients
    
    public var example: ExampleClient
    
    // MARK: - Initializers
    
    public init() {
        manager = Leash.Manager.Builder()
            .scheme(Manager.scheme)
            .host(Manager.host)
            .path(Manager.path)
            .build()
        example = ExampleClient(
            manager: manager
        )
    }
    
}
