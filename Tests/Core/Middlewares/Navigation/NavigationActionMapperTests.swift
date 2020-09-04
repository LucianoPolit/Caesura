//
//  NavigationActionMapperTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

class NavigationActionMapperTests: TestCase {
    
    private let mapper = TestNavigationActionMapper()
    
}

extension NavigationActionMapperTests {
    
    func testDefaultResponse() {
        expect(
            self.mapper.map(.start) as NavigationAction?
        ).to(
            beNil()
        )
    }
    
    func testDefaultArrayResponse() {
        expect(
            self.mapper.map(.start) as [NavigationAction]?
        ).to(
            beNil()
        )
    }
    
}

extension NavigationActionMapperTests {
    
    func testResponse() {
        mapper.handle = { _ in .start }
        guard let action = mapper.map(.start) as NavigationAction?,
            case NavigationAction.start = action else {
            fail()
            return
        }
    }
    
    func testArrayResponse() {
        mapper.handleArray = { _ in [.start] }
        guard let actions = mapper.map(.start) as [NavigationAction]?,
            let action = actions.first,
            case NavigationAction.start = action else {
            fail()
            return
        }
        expect(actions.count) == 1
    }
    
    func testArrayResponseFromSingleMapping() {
        mapper.handle = { _ in .start }
        guard let actions = mapper.map(.start) as [NavigationAction]?,
            let action = actions.first,
            case NavigationAction.start = action else {
            fail()
            return
        }
    }
    
}

private class TestNavigationActionMapper: NavigationActionMapper<TestAction> {
    
    var handle: ((ActionType) -> ActionReturnType)?
    var handleArray: ((ActionType) -> [ActionReturnType])?
    
    override func map(
        _ action: ActionType
    ) -> ActionReturnType? {
        return handle?(action) ?? super.map(action)
    }
    
    override func map(
        _ action: ActionType
    ) -> [ActionReturnType]? {
        return handleArray?(action) ?? super.map(action)
    }
    
}
