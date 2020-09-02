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
    
    let actionHandler: (TestAction) -> Void
    
    init(
        actionHandler: @escaping (TestAction) -> Void
    ) {
        self.actionHandler = actionHandler
    }
    
    func handleAction(
        _ action: TestAction,
        state: TestState
    ) -> TestState {
        actionHandler(action)
        return state
    }
    
}
