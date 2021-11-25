//
//  TestCase.swift
//  Tests
//
//  Created by Luciano Polit on 8/29/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import XCTest
import Nimble

class TestCase: XCTestCase {
    
    override func setUp() {
        AsyncDefaults.timeout = .seconds(2)
        AsyncDefaults.pollInterval = .milliseconds(100)
    }
    
}
