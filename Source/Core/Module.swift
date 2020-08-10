//
//  Module.swift
//
//  Copyright (c) 2020 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import ReSwift

public protocol Module: ModuleProtocol {
    associatedtype StateType: Caesura.StateType
    associatedtype ActionType: Action
    static var initialState: StateType { get }
    static var startAction: ActionType { get }
    static var stopAction: ActionType { get }
    static var reducer: Reducer<ActionType, StateType> { get }
    static func navigationActionMapper() -> NavigationActionMapper<ActionType>
    static func apiActionDispatcher(with api: API) -> APIActionDispatcher<ActionType>
}

extension Module {
    
    public static func actionType() -> Action.Type {
        return ActionType.self
    }
    
    public static func stateType() -> Caesura.StateType.Type {
        return StateType.self
    }
    
    public static func initialState() -> Caesura.StateType {
        return initialState
    }
    
    public static func startAction() -> Action {
        return startAction
    }
    
    public static func stopAction() -> Action {
        return stopAction
    }
    
}

extension Module {
    
    public static var storeKey: String {
        return String(reflecting: StateType.self)
    }
    
    public static func navigationActionMapper() -> NavigationActionMapper<ActionType> {
        return NavigationActionMapper()
    }
    
    public static func apiActionDispatcher(
        with api: API
    ) -> APIActionDispatcher<ActionType> {
        return APIActionDispatcher()
    }
    
}

extension Module {
    
    public static func state(
        from manager: Manager = .main
    ) -> StateType {
        return manager.store.state.value(forKey: storeKey) ?? initialState
    }
    
    public static func dispatch(
        _ action: ActionType,
        from manager: Manager = .main
    ) {
        manager.store.dispatch(action)
    }
    
}

extension Module {
    
    public static func subscribe<S: StoreSubscriber>(
        _ subscriber: S,
        from manager: Manager = .main
    ) where S.StoreSubscriberStateType == StateType {
        subscribe(
            subscriber,
            transform: { $0 }
        )
    }
    
    public static func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S,
        from manager: Manager = .main,
        transform: @escaping ((Subscription<StateType>) -> Subscription<SelectedState>)
    ) where S.StoreSubscriberStateType == SelectedState {
        manager.store.subscribe(
            subscriber,
            transform: {
                transform(
                    $0.select {
                        $0.value(forKey: storeKey) ?? initialState
                    }
                )
            }
        )
    }
    
}

extension Module {
    
    public static func unsubscribe(
        _ subscriber: AnyStoreSubscriber,
        from manager: Manager = .main
    ) {
        manager.store.unsubscribe(subscriber)
    }
    
}
