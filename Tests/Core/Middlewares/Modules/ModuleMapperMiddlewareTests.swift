//
//  ModuleMapperMiddlewareTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class ModuleMapperMiddlewareTests: TestCase { }

extension ModuleMapperMiddlewareTests {
    
    func testNoMapping() {
        var condition = false
        ModuleMapperMiddleware(
            mappers: [
                { _ in nil }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case ApplicationCompletionAction.didFinishLaunching = $0 else { return fail() }
            condition = true
        })(ApplicationCompletionAction.didFinishLaunching)
        expect(condition).to(beTrue())
    }
    
    func testMapToStart() {
        var condition = false
        ModuleMapperMiddleware(
            mappers: [
                { action in
                    switch action {
                    case ApplicationCompletionAction.didFinishLaunching:
                        return [
                            .start(MockModule.self)
                        ]
                    default: break
                    }
                    return nil
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.start = $0 else { return fail() }
            condition = true
        })(ApplicationCompletionAction.didFinishLaunching)
        expect(condition).to(beTrue())
    }
    
    func testMapToStop() {
        var condition = false
        ModuleMapperMiddleware(
            mappers: [
                { action in
                    switch action {
                    case ApplicationCompletionAction.didFinishLaunching:
                        return [
                            .stop(MockModule.self)
                        ]
                    default: break
                    }
                    return nil
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.stop = $0 else { return fail() }
            condition = true
        })(ApplicationCompletionAction.didFinishLaunching)
        expect(condition).to(beTrue())
    }
    
    func testMapToReplace() {
        var condition = false
        ModuleMapperMiddleware(
            mappers: [
                { action in
                    switch action {
                    case ApplicationCompletionAction.didFinishLaunching:
                        return [
                            .replace(with: TestAction.fetch)
                        ]
                    default: break
                    }
                    return nil
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.fetch = $0 else { return fail() }
            condition = true
        })(ApplicationCompletionAction.didFinishLaunching)
        expect(condition).to(beTrue())
    }
    
    func testMapToAll() {
        var number = 0
        ModuleMapperMiddleware(
            mappers: [
                { action in
                    switch action {
                    case ApplicationCompletionAction.didFinishLaunching:
                        return [
                            .start(MockModule.self),
                            .stop(MockModule.self),
                            .replace(with: TestAction.fetch)
                        ]
                    default: break
                    }
                    return nil
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            switch number {
            case 0:
                guard case TestAction.start = $0 else { return fail() }
            case 1:
                guard case TestAction.stop = $0 else { return fail() }
            case 2:
                guard case TestAction.fetch = $0 else { return fail() }
            default:
                fail()
            }
            number += 1
        })(ApplicationCompletionAction.didFinishLaunching)
        expect(number) == 3
    }
    
}

extension ModuleMapperMiddlewareTests {
    
    func testMapToSameAction() {
        var number = 0
        ModuleMapperMiddleware(
            mappers: [
                { action in
                    switch action {
                    case TestAction.start:
                        return [
                            .start(MockModule.self)
                        ]
                    default: break
                    }
                    return nil
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            guard case TestAction.start = $0 else { return fail() }
            number += 1
        })(TestAction.start)
        expect(number) == 1
    }
    
    func testTree() {
        var number = 0
        ModuleMapperMiddleware(
            mappers: [
                { action in
                    switch action {
                    case ThirdTestAction.start:
                        return [
                            .stop(ThirdTestModule.self)
                        ]
                    default: break
                    }
                    return nil
                },
                { action in
                    switch action {
                    case SecondTestAction.start:
                        return [
                            .start(SecondTestModule.self),
                            .start(ThirdTestModule.self)
                        ]
                    default: break
                    }
                    return nil
                },
                { action in
                    switch action {
                    case TestAction.start:
                        return [
                            .start(SecondTestModule.self)
                        ]
                    default: break
                    }
                    return nil
                }
            ]
        ).intercept(
            dispatch: { _ in fail() },
            state: { State() }
        )({
            switch number {
            case 0:
                guard case SecondTestAction.start = $0 else { return fail() }
            case 1:
                guard case ThirdTestAction.stop = $0 else { return fail() }
            default:
                fail()
            }
            number += 1
        })(TestAction.start)
        expect(number) == 2
    }
    
}

private enum SecondTestAction: Action {
    case start
    case stop
}

private class SecondTestModule: Module {
    
    typealias StateType = TestState
    typealias ActionType = SecondTestAction
    
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
        return { $1 }
    }
    
}

private enum ThirdTestAction: Action {
    case start
    case stop
}

private class ThirdTestModule: Module {
    
    typealias StateType = TestState
    typealias ActionType = ThirdTestAction
    
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
        return { $1 }
    }
    
}
