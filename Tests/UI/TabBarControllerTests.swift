//
//  TabBarControllerTests.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import Nimble
import Caesura

class TabBarControllerTests: TestCase { }

extension TabBarControllerTests {
    
    func testDefaultManager() {
        let viewController = TabBarController()
        expect(viewController.manager) === Manager.main
    }
    
}

extension TabBarControllerTests {
    
    func testPresentationControllerDelegateSet() {
        let viewController = TabBarController()
        viewController.asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beAnInstanceOf(DismissHandler.self)
        )
    }
    
    func testPresentationControllerDelegateSetWhenRootViewControllerIsViewController() {
        let viewController = TabBarController().then {
            $0.setViewControllers(
                [UIViewController()],
                animated: false
            )
        }
        viewController.asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beAnInstanceOf(DismissHandler.self)
        )
    }
    
    func testPresentationControllerDelegateSetWhenRootViewControllerIsNavigationController() {
        let viewController = TabBarController().then {
            $0.setViewControllers(
                [
                    NavigationController(
                        rootViewController: UIViewController()
                    )
                ],
                animated: false
            )
        }
        viewController.asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beAnInstanceOf(DismissHandler.self)
        )
    }
    
    func testPresentationControllerDelegateNotSetWhenInNavigationController() {
        let viewController = TabBarController()
        UINavigationController(
            rootViewController: viewController
        ).asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beNil()
        )
    }
    
}

extension TabBarControllerTests {
    
    func testUserSelectionDispatchesCompletion() {
        waitUntil { done in
            let viewControllers = [
                UIViewController(),
                UIViewController()
            ]
            let tabBarController = TestableTabBarController { action in
                guard
                    case NavigationCompletionAction.selectTab(
                        let viewController,
                        _,
                        let previousViewController,
                        _,
                        let origin
                    ) = action
                    else { return }
                expect(previousViewController) === viewControllers[0]
                expect(viewController) === viewControllers[1]
                expect(origin) == .user
                done()
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                viewControllers,
                animated: false
            )
            tabBarController.delegate?.tabBarController?(
                tabBarController,
                didSelect: viewControllers[1]
            )
        }
    }
    
}
