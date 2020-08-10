//
//  NavigationActionMapper.swift
//  List
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
            return .present(
                NavigationController(
                    rootViewController: ViewController()
                )
            )
        case .next(let value):
            return .push(
                Caesura.ViewController().with {
                    $0.title = value
                    $0.view.backgroundColor = .purple
                }
            )
        default: return nil
        }
    }
    
}
