//
//  Module.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import Common

extension Caesura.Module {
    
    public typealias TabTwo = Module
    
}

public class Module: Common.Module {
    
    public typealias StateType = State
    public typealias ActionType = Action
    
    public static var initialState: StateType {
        return .init()
    }
    
    public static var startAction: ActionType {
        return .start
    }
    
    public static var stopAction: ActionType {
        return .stop
    }
    
    public static var reducer: Caesura.Reducer<ActionType, StateType> {
        return Reducer.handleAction
    }
    
    public static func navigationActionMapper() -> Caesura.NavigationActionMapper<ActionType> {
        return NavigationActionMapper()
    }
    
}
