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
        AsyncDefaults.Timeout = 2
        AsyncDefaults.PollInterval = 0.1
    }
    
}
