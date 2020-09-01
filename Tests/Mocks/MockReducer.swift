//
//  MockReducer.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockReducer {
    
    let actionHandler: (MockAction) -> ()
    
    init(
        actionHandler: @escaping (MockAction) -> ()
    ) {
        self.actionHandler = actionHandler
    }
    
    func handleAction(
        _ action: MockAction,
        state: MockState
    ) -> MockState {
        actionHandler(action)
        return state
    }
    
}
