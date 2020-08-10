//
//  NavigationActionMapper.swift
//  Tab
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
            return .set(
                TabBarController()
            )
        default: return nil
        }
    }
    
}
