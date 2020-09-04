//
//  MockNavigationController.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit

class MockNavigationController: UINavigationController {
    
    var setViewControllersCalled = false
    var setViewControllersParameters: ([UIViewController], Bool)?
    var setViewControllersShouldCallSuper = true
    override func setViewControllers(
        _ viewControllers: [UIViewController],
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
    
    var pushViewControllerCalled = false
    var pushViewControllerParamaters: (UIViewController, Bool)?
    override func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        pushViewControllerCalled = true
        pushViewControllerParamaters = (
            viewController,
            animated
        )
    }
    
    var popViewControllerCalled = false
    var popViewControllerParameters: Bool?
    var popViewControllerReturn: UIViewController?
    override func popViewController(
        animated: Bool
    ) -> UIViewController? {
        popViewControllerCalled = true
        popViewControllerParameters = animated
        return popViewControllerReturn
    }
    
    var popToViewControllerCalled = false
    var popToViewControllerParamaters: (UIViewController, Bool)?
    var popToViewControllerReturn: [UIViewController]?
    override func popToViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        popToViewControllerCalled = true
        popToViewControllerParamaters = (
            viewController,
            animated
        )
        return popToViewControllerReturn
    }
    
    var popToRootViewControllerCalled = false
    var popToRootViewControllerParamaters: Bool?
    var popToRootViewControllerReturn: [UIViewController]?
    override func popToRootViewController(
        animated: Bool
    ) -> [UIViewController]? {
        popToRootViewControllerCalled = true
        popToRootViewControllerParamaters = animated
        return popToRootViewControllerReturn
    }
    
}
