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
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.start = $0 else { return fail() }
            condition = true
        })(TestAction.start)
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
        ).intercept(
            dispatch: {
                guard case TestAction.fetch = $0 else { return fail() }
                condition = true
            },
            state: { State() }
        )({ _ in fail() })(TestAction.start)
        expect(condition).to(beTrue())
    }
    
    func testDisabledDoesNotDispatchActions() {
        var condition = false
        let intercept = APIActionDispatcherMiddleware(
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
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.start = $0 else { return }
            condition = true
        })
        intercept(APIActionDispatcherAction.disable)
        intercept(TestAction.start)
        expect(condition).to(beTrue())
    }
    
    func testEnabledAfterBeingDisabledDispatchesActions() {
        var number = 0
        let intercept = APIActionDispatcherMiddleware(
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
                expect(number) == 1
                number += 1
            },
            state: { State() }
        )({
            guard case TestAction.start = $0 else { return }
            number += 1
        })
        intercept(APIActionDispatcherAction.disable)
        intercept(TestAction.start)
        intercept(APIActionDispatcherAction.enable)
        intercept(TestAction.start)
        expect(number) == 2
    }
    
}
