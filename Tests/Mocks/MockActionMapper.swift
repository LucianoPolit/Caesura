//
//  MockActionMapper.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockActionMapper<ActionType: Action, ActionReturnType: Action>: ActionMapper {
    
    let handler: (ActionType) -> [ActionReturnType]?
    
    init(
        handler: @escaping (ActionType) -> [ActionReturnType]?
    ) {
        self.handler = handler
    }
    
    func map(
        _ action: ActionType
    ) -> [ActionReturnType]? {
        return handler(action)
    }
    
}
