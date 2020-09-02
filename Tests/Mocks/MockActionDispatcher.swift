//
//  MockActionDispatcher.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockActionDispatcher<ActionType: Action>: ActionDispatcher {
    
    let handler: (ActionType, (ActionType) -> Void) -> Bool
    
    init(
        handler: @escaping (ActionType, (ActionType) -> Void) -> Bool
    ) {
        self.handler = handler
    }
    
    func dispatch(
        _ action: ActionType,
        to destination: @escaping Destination
    ) -> Bool {
        return handler(action, destination)
    }
    
}
