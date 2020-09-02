//
//  ActionDispatcherMiddlewareTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

class ActionDispatcherMiddlewareTests: TestCase { }

extension ActionDispatcherMiddlewareTests {
    
    func testNoDispatching() {
        var condition = false
        ActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { _, _ in
                    return false
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.start = $0 else { return fail() }
            condition = true
        })(TestAction.start)
        expect(condition).to(beTrue())
    }
    
    func testOnlyOneDispatching() {
        var condition = false
        ActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start: dispatch(.fetch)
                    default: return false
                    }
                    return true
                }
            ]
        ).intercept(
            dispatch: {
                guard case TestAction.fetch = $0 else { return fail() }
                condition = true
            },
            state: { State() }
        )({ _ in fail() })(TestAction.start)
        expect(condition).to(beTrue())
    }
    
    func testMoreThanOneDispatchingFromOneSource() {
        var number = 0
        ActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start:
                        dispatch(.fetch)
                        dispatch(.stop)
                    default: return false
                    }
                    return true
                }
            ]
        ).intercept(
            dispatch: {
                switch number {
                case 0:
                    guard case TestAction.fetch = $0 else { return fail() }
                case 1:
                    guard case TestAction.stop = $0 else { return fail() }
                default:
                    fail()
                }
                number += 1
            },
            state: { State() }
        )({ _ in fail() })(TestAction.start)
        expect(number) == 2
    }
    
    func testMoreThanOneMappingFromDifferentSources() {
        var number = 0
        ActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start: dispatch(.fetch)
                    default: return false
                    }
                    return true
                },
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start: dispatch(.stop)
                    default: return false
                    }
                    return true
                }
            ]
        ).intercept(
            dispatch: {
                switch number {
                case 0:
                    guard case TestAction.fetch = $0 else { return fail() }
                case 1:
                    guard case TestAction.stop = $0 else { return fail() }
                default:
                    fail()
                }
                number += 1
            },
            state: { State() }
        )({ _ in fail() })(TestAction.start)
        expect(number) == 2
    }

}
