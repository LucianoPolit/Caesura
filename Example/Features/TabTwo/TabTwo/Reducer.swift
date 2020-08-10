//
//  Reducer.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import AwesomeUtilities

struct Reducer {
    
    static let handleAction: Caesura.Reducer<Action, State> = { action, state in
        return state.with {
            switch action {
            case .didStart: $0.isStarted = true
            case .didStop: $0.isStarted = false
            default: Logger.shared.logWarning("Action not handled -> \(action)")
            }
        }
    }
    
}
