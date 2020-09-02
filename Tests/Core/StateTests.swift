//
//  StateTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class StateTests: TestCase { }

extension StateTests {
    
    func testFacade() {
        let key = "any"
        let value = TestState()
        let state = State().with {
            $0.set(value, forKey: key)
        }
        expect(state.value(forKey: key)) == value
    }
    
    func testDescription() {
        let state = State().with {
            $0.set(TestState(), forKey: "any")
        }
        expect(state.description) == state.store.description
    }
    
}
