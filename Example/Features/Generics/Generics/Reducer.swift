//
//  Reducer.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import AwesomeUtilities

struct Reducer {
    
    static let handleAction: Caesura.Reducer<Action, State> = { action, state in
        return state.with {
            switch action.unwrap() {
            case let action as CustomStringConvertible: $0.value = action.description
            default: Logger.shared.logWarning("Action not handled -> \(action)")
            }
        }
    }
    
}
