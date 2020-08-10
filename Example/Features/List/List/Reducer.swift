//
//  Reducer.swift
//  List
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
            case .loading: $0.listState = .loading
            case .error(let error): $0.listState = .error(error)
            case .set(let values): $0.listState = .results(values)
            case .add(let value): $0.listState.append(value)
            case .toggleSort: $0.sort.toggle()
            default: Logger.shared.logWarning("Action not handled -> \(action)")
            }
        }
    }
    
}
