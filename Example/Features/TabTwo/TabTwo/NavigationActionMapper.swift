//
//  NavigationActionMapper.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class NavigationActionMapper: Caesura.NavigationActionMapper<Action> {
    
    var navigationController: NavigationController?
    
    override func map(
        _ action: ActionType
    ) -> [ActionReturnType]? {
        switch action {
        case .start:
            navigationController = NavigationController(
                rootViewController: ViewController()
            )
            return [
                .insertTab(
                    navigationController!
                ),
                .selectTab(
                    navigationController!
                )
            ]
        case .stop:
            defer { navigationController = nil }
            return [
                .removeTab(
                    navigationController!
                )
            ]
        default: return nil
        }
    }
    
}
