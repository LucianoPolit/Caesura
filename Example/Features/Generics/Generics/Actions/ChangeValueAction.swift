//
//  ChangeValueAction.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

struct ChangeValueAction<T: Codable & CustomStringConvertible>: ActionProtocol, CustomStringConvertible {
    
    let value: T
    
    var description: String {
        return value.description
    }
    
}

extension ChangeValueAction: StandardActionConvertible {
    
    init(
        action: StandardAction
    ) throws {
        guard action.name == Self.key else { throw ActionError.invalidName }
        value = try action.decodedPayload()
    }
    
    func toStandard() -> StandardAction? {
        return StandardAction(
            name: Self.key,
            payload: value
        )
    }
    
}
