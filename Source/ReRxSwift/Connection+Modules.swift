//
//  Connection+Modules.swift
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
#if !COCOAPODS
import Caesura
#endif

public typealias DoubleModuleStateContainer<M1: Module, M2: Module> =
    DoubleStateContainer<M1.StateType, M2.StateType>

public typealias TripleModuleStateContainer<M1: Module, M2: Module, M3: Module> =
    TripleStateContainer<M1.StateType, M2.StateType, M3.StateType>

public struct DoubleStateContainer<StateType1, StateType2>: StateType {
    
    public let first: StateType1
    public let second: StateType2
    
    public init(
        _ first: StateType1,
        _ second: StateType2
    ) {
        self.first = first
        self.second = second
    }
    
}

public struct TripleStateContainer<StateType1, StateType2, StateType3>: StateType {
    
    public let first: StateType1
    public let second: StateType2
    public let third: StateType3
    
    public init(
        _ first: StateType1,
        _ second: StateType2,
        _ third: StateType3
    ) {
        self.first = first
        self.second = second
        self.third = third
    }
    
}

extension Connection where State == Caesura.State {
    
    public static func toModules<M1: Module, M2: Module>(
        _ module1: M1.Type,
        _ module2: M2.Type,
        manager: Manager = Manager.main,
        mapStateToProps: @escaping MapStateToProps<DoubleModuleStateContainer<M1, M2>, Props>,
        mapDispatchToEvents: @escaping MapDispatchToActions
    ) -> Connection<State, Props, Actions> {
        return .toManager(
            manager,
            transform: {
                return DoubleStateContainer(
                    $0.value(forKey: M1.storeKey) ?? M1.initialState,
                    $0.value(forKey: M2.storeKey) ?? M2.initialState
                )
            },
            mapStateToProps: mapStateToProps,
            mapDispatchToEvents: mapDispatchToEvents
        )
    }
    
}

extension Connection where State == Caesura.State {
    
    public static func toModules<M1: Module, M2: Module, M3: Module>(
        _ module1: M1.Type,
        _ module2: M2.Type,
        _ module3: M3.Type,
        manager: Manager = Manager.main,
        mapStateToProps: @escaping MapStateToProps<TripleModuleStateContainer<M1, M2, M3>, Props>,
        mapDispatchToEvents: @escaping MapDispatchToActions
    ) -> Connection<State, Props, Actions> {
        return .toManager(
            manager,
            transform: {
                return TripleStateContainer(
                    $0.value(forKey: M1.storeKey) ?? M1.initialState,
                    $0.value(forKey: M2.storeKey) ?? M2.initialState,
                    $0.value(forKey: M3.storeKey) ?? M3.initialState
                )
            },
            mapStateToProps: mapStateToProps,
            mapDispatchToEvents: mapDispatchToEvents
        )
    }
    
}
