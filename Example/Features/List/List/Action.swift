//
//  Action.swift
//  List
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import Common

public enum Action: Caesura.Action, Equatable {
    case start
    case fetch
    case loading
    case error(Error)
    case set([String])
    case add(String)
    case toggleSort
    case next(String)
}

extension Action: StandardActionConvertible {
    
    public init(
        action: StandardAction
    ) throws {
        guard let key = CodingKeys(rawValue: action.name)
            else { throw StandardActionError.keyNotFound }
        switch key {
        case .start: self = .start
        case .fetch: self = .fetch
        case .loading: self = .loading
        case .toggleSort: self = .toggleSort
        case .error: try self = .error(action.decodedPayload())
        case .set: try self = .set(action.decodedPayload())
        case .add: try self = .add(action.decodedPayload())
        case .next: try self = .next(action.decodedPayload())
        }
    }
    
    public func toStandard() -> StandardAction? {
        switch self {
        case .start, .fetch, .loading, .toggleSort: return StandardAction(name: name)
        case .error(let error): return StandardAction(name: name, payload: error)
        case .set(let array): return StandardAction(name: name, payload: array)
        case .add(let string): return StandardAction(name: name, payload: string)
        case .next(let string): return StandardAction(name: name, payload: string)
        }
    }
    
}

private extension Action {
    
    enum CodingKeys: String {
        case start
        case fetch
        case loading
        case error
        case set
        case add
        case toggleSort
        case next
    }
    
    var key: CodingKeys {
        switch self {
        case .start: return .start
        case .fetch: return .fetch
        case .loading: return .loading
        case .error: return .error
        case .set: return .set
        case .add: return .add
        case .toggleSort: return .toggleSort
        case .next: return .next
        }
    }
    
    var name: String {
        return key.rawValue
    }
    
}
