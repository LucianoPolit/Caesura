//
//  MockActionRegistrable.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockActionRegistrable: ActionRegistrable {
    
    let completion: (Action.Type) -> Void
    
    init(
        completion: @escaping (Action.Type) -> Void
    ) {
        self.completion = completion
    }
    
    func register(
        actionType: Action.Type
    ) {
        completion(actionType)
    }
    
}
