//
//  DismissHandlerTests.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import Nimble
import Caesura

class DismissHandlerTests: TestCase { }

extension DismissHandlerTests {
    
    func testProgrammaticallyDismissDispatchesCompletion() {
        waitUntil { done in
            var viewController: ViewController!
            viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewController) === dismissedViewController
                expect(origin) == .code
                done()
            }
            UIViewController().asRootOfKeyWindow().present(
                viewController,
                animated: false
            ) {
                viewController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
    func testProgrammaticallyDismissOnParentDispatchesCompletion() {
        waitUntil { done in
            let viewController = UIViewController()
            let rootViewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewController) === dismissedViewController
                expect(origin) == .code
                done()
            }
            rootViewController.asRootOfKeyWindow().present(
                viewController,
                animated: false
            ) {
                rootViewController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
    func testProgrammaticallyDismissDispatchesMultipleCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let rootViewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        let origin
                    ) = action
                    else { return }
                defer { number += 1 }
                switch number {
                case 0:
                    expect(secondViewController) === dismissedViewController
                    expect(origin) == .code
                case 1:
                    expect(firstViewController) === dismissedViewController
                    expect(origin) == .code
                default:
                    fail()
                }
                if number == 1 { done() }
            }
            rootViewController.asRootOfKeyWindow().present(
                firstViewController,
                animated: false
            ) {
                firstViewController.present(
                    secondViewController,
                    animated: false
                ) {
                    rootViewController.dismiss(
                        animated: false,
                        completion: nil,
                        programmatically: ()
                    )
                }
            }
        }
    }
    
    func testProgrammaticallyDismissCallsCompletion() {
        waitUntil { done in
            let viewController = ViewController()
            UIViewController().asRootOfKeyWindow().present(
                viewController,
                animated: false
            ) {
                viewController.dismiss(
                    animated: false,
                    completion: done,
                    programmatically: ()
                )
            }
        }
    }
    
    func testUserDismissDispatchesCompletion() {
        waitUntil { done in
            var viewController: ViewController!
            viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewController) === dismissedViewController
                expect(origin) == .user
                done()
            }
            UIViewController().asRootOfKeyWindow().present(
                viewController,
                animated: false
            ) {
                guard let presentationController = viewController.presentationController else { return fail() }
                if #available(iOS 13.0, *) {
                    presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
                }
            }
        }
    }
    
}

extension DismissHandlerTests {
    
    func testViewControllerResponsibleOfViewController() {
        waitUntil { done in
            var viewController: ViewController!
            viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        _
                    ) = action
                    else { return }
                expect(viewController) === dismissedViewController
                done()
            }
            UIViewController().asRootOfKeyWindow().present(
                viewController,
                animated: false
            ) {
                viewController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
    func testNavigationControllerResponsibleOfViewController() {
        waitUntil { done in
            var navigationController: UINavigationController!
            let viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        _
                    ) = action
                    else { return }
                expect(navigationController) === dismissedViewController
                done()
            }
            navigationController = UINavigationController(
                rootViewController: viewController
            )
            UIViewController().asRootOfKeyWindow().present(
                navigationController,
                animated: false
            ) {
                viewController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
    func testTabBarControllerResponsibleOfViewController() {
        waitUntil { done in
            var tabBarController: UITabBarController!
            let viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        _
                    ) = action
                    else { return }
                expect(tabBarController) === dismissedViewController
                done()
            }
            tabBarController = UITabBarController().then {
                $0.setViewControllers(
                    [viewController],
                    animated: false
                )
            }
            UIViewController().asRootOfKeyWindow().present(
                tabBarController,
                animated: false
            ) {
                viewController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
    func testTabBarControllerResponsibleOfNavigationController() {
        waitUntil { done in
            var tabBarController: UITabBarController!
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        _
                    ) = action
                    else { return }
                expect(tabBarController) === dismissedViewController
                done()
            }
            tabBarController = UITabBarController().then {
                $0.setViewControllers(
                    [navigationController],
                    animated: false
                )
            }
            UIViewController().asRootOfKeyWindow().present(
                tabBarController,
                animated: false
            ) {
                navigationController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
    func testTabBarControllerResponsibleOfNavigationControllerResponsibleOfViewController() {
        waitUntil { done in
            var tabBarController: UITabBarController!
            let viewController = TestableViewController { action in
                guard
                    case NavigationCompletionAction.dismiss(
                        let dismissedViewController,
                        _
                    ) = action
                    else { return }
                expect(tabBarController) === dismissedViewController
                done()
            }
            let navigationController = UINavigationController(
                rootViewController: viewController
            )
            tabBarController = UITabBarController().then {
                $0.setViewControllers(
                    [navigationController],
                    animated: false
                )
            }
            UIViewController().asRootOfKeyWindow().present(
                tabBarController,
                animated: false
            ) {
                viewController.dismiss(
                    animated: false,
                    completion: nil,
                    programmatically: ()
                )
            }
        }
    }
    
}
