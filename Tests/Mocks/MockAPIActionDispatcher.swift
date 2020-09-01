//
//  MockAPIActionDispatcher.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockAPIActionDispatcher: APIActionDispatcher<MockAction> {
    
    let api: API
    let actionHandler: (MockAction) -> ()
    
    init(
        api: API,
        actionHandler: @escaping (MockAction) -> ()
    ) {
        self.api = api
        self.actionHandler = actionHandler
    }
    
    override func dispatch(
        _ action: ActionType,
        to destination: @escaping Destination
    ) -> Bool {
        switch action {
        case .fetch: actionHandler(action)
        default: return super.dispatch(action, to: destination)
        }
        return true
    }
    
}
