//
//  ViewControllerTests.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import Nimble
import Caesura

class ViewControllerTests: TestCase { }

extension ViewControllerTests {
    
    func testDefaultManager() {
        let viewController = ViewController()
        expect(viewController.manager) === Manager.main
    }
    
}

extension ViewControllerTests {
    
    func testPresentationControllerDelegateSet() {
        let viewController = ViewController()
        viewController.asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beAnInstanceOf(DismissHandler.self)
        )
    }
    
    func testPresentationControllerDelegateNotSetWhenInNavigationController() {
        let viewController = ViewController()
        UINavigationController(
            rootViewController: viewController
        ).asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beNil()
        )
    }
    
    func testPresentationControllerDelegateNotSetWhenInTabBarController() {
        let viewController = ViewController()
        UITabBarController().asRootOfKeyWindow().do {
            $0.setViewControllers(
                [viewController],
                animated: false
            )
        }
        expect(
            viewController.presentationController?.delegate
        ).to(
            beNil()
        )
    }
    
}

extension ViewControllerTests {
    
    func testPresentDispatchesCompletion() {
        waitUntil { done in
            let viewControllerToPresent = UIViewController()
            var viewController: ViewController!
            viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.present(
                        let presentedViewController
                    ) = action
                    else { return }
                expect(viewControllerToPresent) === presentedViewController
                done()
            }
            viewController.asRootOfKeyWindow().present(
                viewControllerToPresent,
                animated: false,
                completion: nil
            )
        }
    }
    
    func testPresentCallsCompletion() {
        waitUntil { done in
            let viewControllerToPresent = UIViewController()
            let viewController = ViewController()
            viewController.asRootOfKeyWindow().present(
                viewControllerToPresent,
                animated: false,
                completion: done
            )
        }
    }
    
}
