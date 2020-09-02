//
//  MockNavigationActionMapper.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockNavigationActionMapper: NavigationActionMapper<TestAction> {
    
    let actionHandler: (TestAction) -> Void
    
    init(
        actionHandler: @escaping (TestAction) -> Void
    ) {
        self.actionHandler = actionHandler
    }
    
    override func map(
        _ action: ActionType
    ) -> ActionReturnType? {
        switch action {
        case .start: actionHandler(.start)
        default: break
        }
        return nil
    }
    
}
