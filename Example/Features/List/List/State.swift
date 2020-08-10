//
//  State.swift
//  List
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import Common
import Then

public struct State: StateType, Then, Equatable {
    
    var listState: ListState = .empty
    var sort: Sort = .ascending
    
}

extension State {
    
    public enum ListState: Equatable {
        case empty
        case loading
        case results([String])
        case error(Error)
    }
    
}

extension State {
    
    public enum Sort: Equatable {
        case ascending
        case descending
    }
    
}

extension State.ListState {
    
    var values: [String] {
        guard case .results(let values) = self else { return [] }
        return values
    }
    
    mutating func append(
        _ value: String
    ) {
        guard case .results(var values) = self else { return }
        values.append(value)
        self = .results(values)
    }
    
}

extension State.Sort {
    
    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
    
}
