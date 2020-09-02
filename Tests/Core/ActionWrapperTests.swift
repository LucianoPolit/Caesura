//
//  ActionWrapperTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

class ActionWrapperTests: TestCase { }

extension ActionWrapperTests {
    
    func testWrapper() {
        let action = SomeAction()
        let wrapper = ActionWrapper<WrappedActionProtocol>(action)
        expect(wrapper.unwrap()) === action
    }
    
}

extension ActionWrapperTests {
    
    func testDispatch() {
        waitUntil { done in
            ModuleWithWrappedAction.dispatch(
                SomeAction(),
                from: MockManager { action in
                    guard let wrapper = action as? ActionWrapper<WrappedActionProtocol> else { return }
                    expect(wrapper.unwrap()).to(beAnInstanceOf(SomeAction.self))
                    done()
                }
            )
        }
    }
    
}

private protocol WrappedActionProtocol: Action { }

private class SomeAction: WrappedActionProtocol { }

private class ModuleWithWrappedAction: Module {
    
    typealias StateType = TestState
    typealias ActionType = ActionWrapper<WrappedActionProtocol>
    
    static var initialState: StateType {
        return .init()
    }
    
    static var startAction: ActionType {
        return .init(SomeAction())
    }
    
    static var stopAction: ActionType {
        return .init(SomeAction())
    }
    
    static var reducer: Reducer<ActionType, StateType> {
        return { $1 }
    }
    
}
