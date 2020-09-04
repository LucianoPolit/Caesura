//
//  NavigationActionMapperMiddlewareTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class NavigationActionMapperMiddlewareTests: TestCase { }

extension NavigationActionMapperMiddlewareTests {
    
    func testNoMapping() {
        var condition = false
        NavigationActionMapperMiddleware(
            mappers: [
                MockActionMapper<TestAction, TestAction> { _ in
                    return nil
                }
            ]
        ).testIntercept(
            withAction: TestAction.start,
            next: {
                guard case TestAction.start = $0 else { return fail() }
                condition = true
            }
        )
        expect(condition).to(beTrue())
    }
    
    func testOnlyOneMapping() {
        var condition = false
        NavigationActionMapperMiddleware(
            mappers: [
                MockActionMapper<TestAction, TestAction> { action in
                    switch action {
                    case .start: return [.stop]
                    default: return nil
                    }
                }
            ]
        ).testIntercept(
            withAction: TestAction.start,
            next: {
                guard case TestAction.stop = $0 else { return fail() }
                condition = true
            }
        )
        expect(condition).to(beTrue())
    }
    
    func testDidFinishLaunchingDispatchesStart() {
        var number = 0
        NavigationActionMapperMiddleware(
            mappers: []
        ).testIntercept(
            withAction: ApplicationCompletionAction.didFinishLaunching,
            next: {
                switch number {
                case 0:
                    guard case ApplicationCompletionAction.didFinishLaunching = $0 else { return fail() }
                case 1:
                    guard case NavigationAction.start = $0 else { return fail() }
                default:
                    fail()
                }
                number += 1
            }
        )
        expect(number) == 2
    }
    
}
