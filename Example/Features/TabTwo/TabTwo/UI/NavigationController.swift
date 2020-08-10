//
//  NavigationController.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import Caesura

class NavigationController: Caesura.NavigationController, Connectable {
    
    lazy var connection = Connection.toModule(
        Module.self,
        mapStateToProps: Self.mapStateToProps,
        mapDispatchToEvents: Self.mapDispatchToEvents
    )
    
    override func didMove(
        toParent parent: UIViewController?
    ) {
        super.didMove(toParent: parent)
        events.didMoveToParent(parent)
    }
    
}
