//
//  NavigationActionMapper.swift
//  TabOne
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class NavigationActionMapper: Caesura.NavigationActionMapper<Action> {
    
    override func map(
        _ action: ActionType
    ) -> ActionReturnType? {
        switch action {
        case .start:
            return .insertTab(
                NavigationController(
                    rootViewController: ViewController()
                )
            )
        default: return nil
        }
    }
    
}
