//
//  APIActionDispatcherMiddlewareTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class APIActionDispatcherMiddlewareTests: TestCase { }

extension APIActionDispatcherMiddlewareTests {
    
    func testEnabledDoesNotDispatchActions() {
        var condition = false
        APIActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { _, _ in
                    return false
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
    
    func testEnabledDispatchesActions() {
        var condition = false
        APIActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start: dispatch(.fetch)
                    default: return false
                    }
                    return true
                }
            ]
        ).testIntercept(
            withAction: TestAction.start,
            dispatch: {
                guard case TestAction.fetch = $0 else { return fail() }
                condition = true
            }
        )
        expect(condition).to(beTrue())
    }
    
    func testDisabledDoesNotDispatchActions() {
        var condition = false
        APIActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start: dispatch(.fetch)
                    default: return false
                    }
                    return true
                }
            ]
        ).testIntercept(
            withActions: [
                APIActionDispatcherAction.disable,
                TestAction.start
            ],
            next: {
                guard case TestAction.start = $0 else { return }
                condition = true
            }
        )
        expect(condition).to(beTrue())
    }
    
    func testEnabledAfterBeingDisabledDispatchesActions() {
        var number = 0
        APIActionDispatcherMiddleware(
            dispatchers: [
                MockActionDispatcher<TestAction> { action, dispatch in
                    switch action {
                    case .start: dispatch(.fetch)
                    default: return false
                    }
                    return true
                }
            ]
        ).testIntercept(
            withActions: [
                APIActionDispatcherAction.disable,
                TestAction.start,
                APIActionDispatcherAction.enable,
                TestAction.start
            ],
            dispatch: {
                guard case TestAction.fetch = $0 else { return fail() }
                expect(number) == 1
                number += 1
            },
            next: {
                guard case TestAction.start = $0 else { return }
                number += 1
            }
        )
        expect(number) == 2
    }
    
}
