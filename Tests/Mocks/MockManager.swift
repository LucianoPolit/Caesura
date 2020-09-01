//
//  MockManager.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
@testable import Caesura

class MockManager: Manager {
    
    private let actionHandler: (Action) -> Void
    
    init(
        actionHandler: @escaping (Action) -> Void
    ) {
        self.actionHandler = actionHandler
    }
    
    override var store: Store {
        return Store(
            reducer: {
                self.actionHandler($0)
                return $1 ?? .init()
            },
            state: nil,
            middleware: [],
            automaticallySkipsRepeats: false
        )
    }
    
}
