//
//  ModuleTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class ModuleTests: TestCase { }

extension ModuleTests {
    
    func testModuleProtocolDefaultConformance() {
        let TestModuleProtocol = TestModule.self as ModuleProtocol.Type
        guard TestModuleProtocol.actionType() == TestModule.ActionType.self,
            TestModuleProtocol.stateType() == TestModule.StateType.self,
            let initialState = TestModuleProtocol.initialState() as? TestModule.StateType,
            let startAction = TestModuleProtocol.startAction() as? TestModule.ActionType,
            let stopAction = TestModuleProtocol.stopAction() as? TestModule.ActionType
            else { return fail() }
        expect(initialState) == TestModule.initialState
        expect(startAction) == TestModule.startAction
        expect(stopAction) == TestModule.stopAction
    }
    
}

extension ModuleTests {
    
    func testDefaultStoreKey() {
        expect(TestModule.storeKey) == String(reflecting: TestModule.StateType.self)
    }
    
    func testDefaultNavigationActionMapper() {
        expect(TestModule.navigationActionMapper()).toNot(beNil())
    }
    
    func testDefaultAPIActionDispatcher() {
        expect(TestModule.apiActionDispatcher(with: TestAPI())).toNot(beNil())
    }
    
}

extension ModuleTests {
    
    func testDefaultState() {
        expect(TestModule.state()) == TestModule.initialState
    }
    
    func testDispatch() {
        waitUntil { done in
            TestModule.dispatch(
                .start,
                from: MockManager { action in
                    guard case TestAction.start = action else { return }
                    done()
                }
            )
        }
    }
    
}

extension ModuleTests {
    
    func testSubscribe() {
        waitUntil { done in
            TestModule.subscribe(
                MockStoreSusbcriber<TestState> { _ in
                    done()
                },
                from: .init()
            )
        }
    }
    
    func testSubscribeToSubState() {
        waitUntil { done in
            TestModule.subscribe(
                MockStoreSusbcriber<Int> { _ in
                    done()
                },
                from: .init()
            ) { $0.select { $0.value } }
        }
    }
    
    func testUnsubscribe() {
        var condition = false
        let manager = Manager()
        let subscriber = MockStoreSusbcriber<TestState> { state in
            condition = state.value == 1
        }
        TestModule.subscribe(
            subscriber,
            from: manager
        )
        TestModule.unsubscribe(
            subscriber,
            from: manager
        )
        manager.store.dispatch(TestAction.fetch)
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
}

private class TestModule: Module {
    
    typealias StateType = TestState
    typealias ActionType = TestAction
    
    static var initialState: StateType {
        return .init()
    }
    
    static var startAction: ActionType {
        return .start
    }
    
    static var stopAction: ActionType {
        return .stop
    }
    
    static var reducer: Reducer<ActionType, StateType> {
        return {
            guard $0 == .fetch else { return $1 }
            return $1.with { $0.value += 1 }
        }
    }
    
}

private class MockStoreSusbcriber<T>: StoreSubscriber {
    
    let stateHandler: (T) -> Void
    
    init(
        stateHandler: @escaping (T) -> Void
    ) {
        self.stateHandler = stateHandler
    }
    
    func newState(
        state: T
    ) {
        stateHandler(state)
    }
    
}
