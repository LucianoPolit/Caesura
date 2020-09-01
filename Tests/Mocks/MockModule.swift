//
//  MockModule.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockModule: Module {
    
    typealias StateType = MockState
    typealias ActionType = MockAction
    
    static var initialState: StateType {
        return .init()
    }
    
    static var startAction: ActionType {
        return .start
    }
    
    static var stopAction: ActionType {
        return .stop
    }
    
    static var reducerFactory: (() -> Reducer<ActionType, StateType>)?
    static var reducer: Reducer<ActionType, StateType> {
        defer { reducerFactory = nil }
        return reducerFactory?() ?? { $1 }
    }
    
    static var navigationActionMapperFactory: (() -> MockNavigationActionMapper)?
    static func navigationActionMapper() -> NavigationActionMapper<ActionType> {
        defer { navigationActionMapperFactory = nil }
        return navigationActionMapperFactory?() ?? .init()
    }
    
    static var apiActionDispatcherFactory: ((API) -> MockAPIActionDispatcher)?
    static func apiActionDispatcher(
        with api: API
    ) -> APIActionDispatcher<ActionType> {
        defer { apiActionDispatcherFactory = nil }
        return apiActionDispatcherFactory?(api) ?? .init(api: api) { _ in }
    }
    
}
