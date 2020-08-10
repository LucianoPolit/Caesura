//
//  Module.swift
//  Tab
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import Common

extension Caesura.Module {
    
    public typealias Tab = TabModule
    
}

public class TabModule: Common.Module {
    
    public typealias StateType = State
    public typealias ActionType = Action
    
    public static var initialState: StateType {
        return .init()
    }
    
    public static var startAction: ActionType {
        return .start
    }
    
    public static var reducer: Caesura.Reducer<ActionType, StateType> {
        return { $1 }
    }
    
    public static func navigationActionMapper() -> Caesura.NavigationActionMapper<ActionType> {
        return NavigationActionMapper()
    }
    
}
