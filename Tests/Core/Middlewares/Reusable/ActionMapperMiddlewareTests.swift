//
//  ActionMapperMiddlewareTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

class ActionMapperMiddlewareTests: TestCase { }

extension ActionMapperMiddlewareTests {
    
    func testNoMapping() {
        var condition = false
        ActionMapperMiddleware(
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
        ActionMapperMiddleware(
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
    
    func testMoreThanOneMappingFromOneSource() {
        var number = 0
        ActionMapperMiddleware(
            mappers: [
                MockActionMapper<TestAction, TestAction> { action in
                    switch action {
                    case .start: return [.fetch, .stop]
                    default: return nil
                    }
                }
            ]
        ).testIntercept(
            withAction: TestAction.start,
            next: {
                switch number {
                case 0:
                    guard case TestAction.fetch = $0 else { return fail() }
                case 1:
                    guard case TestAction.stop = $0 else { return fail() }
                default:
                    fail()
                }
                number += 1
            }
        )
        expect(number) == 2
    }
    
    func testMoreThanOneMappingFromDifferentSources() {
        var number = 0
        ActionMapperMiddleware(
            mappers: [
                MockActionMapper<TestAction, TestAction> { action in
                    switch action {
                    case .start: return [.fetch]
                    default: return nil
                    }
                },
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
                switch number {
                case 0:
                    guard case TestAction.fetch = $0 else { return fail() }
                case 1:
                    guard case TestAction.stop = $0 else { return fail() }
                default:
                    fail()
                }
                number += 1
            }
        )
        expect(number) == 2
    }
    
}
