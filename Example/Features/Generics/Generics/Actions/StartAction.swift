//
//  StartAction.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

struct StartAction: ActionProtocol { }

extension StartAction: StandardActionConvertible {
    
    init(
        action: StandardAction
    ) throws {
        guard action.name == Self.key else { throw ActionError.invalidName }
    }
    
    func toStandard() -> StandardAction? {
        return StandardAction(
            name: Self.key
        )
    }
    
}
