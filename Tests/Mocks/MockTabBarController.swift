//
//  MockTabBarController.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit

class MockTabBarController: UITabBarController {
    
    var setViewControllersCalled = false
    var setViewControllersParameters: ([UIViewController]?, Bool)?
    var setViewControllersShouldCallSuper = true
    override func setViewControllers(
        _ viewControllers: [UIViewController]?,
        animated: Bool
    ) {
        setViewControllersCalled = true
        setViewControllersParameters = (
            viewControllers,
            animated
        )
        guard setViewControllersShouldCallSuper else { return }
        super.setViewControllers(
            viewControllers,
            animated: animated
        )
    }
    
}
