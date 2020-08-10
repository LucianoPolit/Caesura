//
//  Action.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

enum ActionError: Error {
    case invalidName
}

public protocol ActionProtocol: Caesura.Action { }

public class Action: ActionWrapper<ActionProtocol>, StandardActionConvertible {
    
    static let allTypes: [StandardActionConvertible.Type] = [
        StartAction.self,
        ChangeValueAction<Int>.self,
        ChangeValueAction<String>.self,
        ChangeValueAction<Bool>.self
    ]
    
    public required init(
        _ value: ActionProtocol
    ) {
        super.init(value)
    }
    
    public required init(
        action: StandardAction
    ) throws {
        guard let convertedAction = Self.allTypes
            .compactMap({ try? $0.init(action: action) })
            .first as? ActionProtocol
            else {
                throw ActionError.invalidName
            }
        super.init(convertedAction)
    }
    
    public func toStandard() -> StandardAction? {
        return (unwrap() as? StandardActionConvertible)?.toStandard()
    }
    
}

extension Action: CustomStringConvertible {
    
    public var description: String {
        return String(
            describing: type(
                of: unwrap()
            )
        )
    }
    
}

extension ActionProtocol {
    
    func wrapped() -> Action {
        return Action(self)
    }
    
}
