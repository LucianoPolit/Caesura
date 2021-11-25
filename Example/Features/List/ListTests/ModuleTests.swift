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
            equal(State())
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
        #if arch(x86_64)
        expect {
            let action = Module.stopAction
            guard action == Module.stopAction
                else { throw Error.unknown }
        }.to(
            throwAssertion()
        )
        #endif
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
