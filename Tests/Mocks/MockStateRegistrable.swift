//
//  MockStateRegistrable.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class MockStateRegistrable: StateRegistrable {
    
    let completion: (StateType.Type) -> ()
    
    init(
        completion: @escaping (StateType.Type) -> ()
    ) {
        self.completion = completion
    }
    
    func register(
        stateType: StateType.Type
    ) {
        completion(stateType)
    }
    
}
