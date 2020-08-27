//
//  MockAPI.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
@testable import API

public class MockAPI: API.Manager {
    
    public var mockExample: MockExampleClient {
        return example as! MockExampleClient
    }
    
    public override init() {
        super.init()
        example = MockExampleClient(
            manager: manager
        )
    }
    
}
