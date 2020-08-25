//
//  NavigationActionMapper.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class NavigationActionMapper: Caesura.NavigationActionMapper<Action> {
    
    override func map(
        _ action: ActionType
    ) -> ActionReturnType? {
        switch action.unwrap() {
        case is StartAction:
            return .set(
                NavigationController(
                    rootViewController: ViewController()
                )
            )
        default: return nil
        }
    }
    
}
