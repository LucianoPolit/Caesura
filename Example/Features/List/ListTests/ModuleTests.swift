//
//  ModuleTests.swift
//  ListTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Common
import XCTest
import Nimble
import CommonTests
@testable import List

class ModuleTests: XCTestCase { }

extension ModuleTests {
    
    func testInitialState() {
        expect(
            Module.initialState
        ).to(
            equal(.init())
        )
    }
    
    func testStartAction() {
        expect(
            Module.startAction
        ).to(
            equal(.start)
        )
    }
    
    func testStopAction() {
        expect(
            try {
                let action = Module.stopAction
                guard action == Module.stopAction
                    else { throw Error.unknown }
                return nil
            }()
        ).to(
            throwAssertion()
        )
    }
    
    func testNavigationActionMapper() {
        expect(
            Module.navigationActionMapper()
        ).to(
            beAKindOf(NavigationActionMapper.self)
        )
    }
    
    func testAPIActionDispatcher() {
        expect(
            Module.apiActionDispatcher(
                with: MockAPI()
            )
        ).to(
            beAKindOf(
                APIActionDispatcher.self
            )
        )
    }
    
}
