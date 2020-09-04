//
//  NavigationControllerTests.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import Nimble
import Caesura

class NavigationControllerTests: TestCase { }

extension NavigationControllerTests {
    
    func testDefaultManager() {
        let viewController = ViewController()
        expect(viewController.manager) === Manager.main
    }
    
}

extension NavigationControllerTests {
    
    func testPresentationControllerDelegateSet() {
        let viewController = NavigationController()
        viewController.asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beAnInstanceOf(DismissHandler.self)
        )
    }
    
    func testPresentationControllerDelegateSetWhenRootViewControllerIsDefined() {
        let viewController = NavigationController(
            rootViewController: UIViewController()
        )
        viewController.asRootOfKeyWindow()
        expect(
            viewController.presentationController?.delegate
        ).to(
            beAnInstanceOf(DismissHandler.self)
        )
    }
    
    func testPresentationControllerDelegateNotSetWhenInTabBarController() {
        let viewController = NavigationController()
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

extension NavigationControllerTests {
    
    func testSetRootViewControllerDoesNotDispatchCompletion() {
        var condition = false
        let navigationController = TestableNavigationController { action in
            switch action {
            case NavigationCompletionAction.setNavigation,
                 NavigationCompletionAction.push,
                 NavigationCompletionAction.pop:
                condition = true
            default: break
            }
        }
        navigationController.setViewControllers(
            [UIViewController()],
            animated: false
        )
        navigationController.asRootOfKeyWindow()
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
    func testSetViewControllersDispatchesCompletion() {
        var number = 0
        var call: (() -> Void)!
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let thirdViewController = UIViewController()
        let fourthViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            guard
                case NavigationCompletionAction.setNavigation(
                    let viewControllers,
                    let previousViewControllers
                ) = action
                else { return }
            defer { number += 1 }
            switch number {
            case 0:
                expect(viewControllers) == [firstViewController, secondViewController]
                expect(previousViewControllers).to(beEmpty())
                call()
            case 1:
                expect(viewControllers) == [thirdViewController, fourthViewController]
                expect(previousViewControllers) == [firstViewController, secondViewController]
                call()
            default:
                fail()
            }
        }
        navigationController.asRootOfKeyWindow()
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
        }
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    thirdViewController,
                    fourthViewController
                ],
                animated: false
            )
        }
    }
    
    func testSetViewControllersDoesNotDispatchCompletion() {
        var call: (() -> Void)!
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            switch action {
            case NavigationCompletionAction.setNavigation,
                 NavigationCompletionAction.push,
                 NavigationCompletionAction.pop:
                call()
            default: break
            }
        }
        navigationController.asRootOfKeyWindow()
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
        }
        var condition = false
        call = {
            condition = true
        }
        navigationController.setViewControllers(
            [
                firstViewController,
                secondViewController
            ],
            animated: false
        )
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
    func testSetViewControllersWithoutShowDispatchesCompletion() {
        var number = 0
        var call: (() -> Void)!
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            guard
                case NavigationCompletionAction.setNavigation(
                    let viewControllers,
                    let previousViewControllers
                ) = action
                else { return }
            defer { number += 1 }
            switch number {
            case 0:
                expect(viewControllers) == [firstViewController, secondViewController]
                expect(previousViewControllers).to(beEmpty())
                call()
            case 1:
                expect(viewControllers) == [secondViewController]
                expect(previousViewControllers) == [firstViewController, secondViewController]
                call()
            default:
                fail()
            }
        }
        navigationController.asRootOfKeyWindow()
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
        }
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    secondViewController
                ],
                animated: false
            )
        }
    }
    
    func testSetViewControllersDispatchesPopCompletion() {
        var number = 0
        var call: (() -> Void)!
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            if number == 0,
                case NavigationCompletionAction.setNavigation(
                    let viewControllers,
                    let previousViewControllers
                ) = action {
                expect(viewControllers) == [firstViewController, secondViewController]
                expect(previousViewControllers).to(beEmpty())
                number += 1
                call()
            }
            if number == 1,
                case NavigationCompletionAction.pop(
                    let viewController,
                    let origin
                ) = action {
                expect(viewController) === secondViewController
                expect(origin) == .code
                number += 1
                call()
            }
        }
        navigationController.asRootOfKeyWindow()
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
        }
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController
                ],
                animated: false
            )
        }
    }
    
    func testSetViewControllersDoesNotDispatchPopCompletionWhenEmpty() {
        var number = 0
        var call: (() -> Void)!
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            switch number {
            case 0, 2:
                guard
                    case NavigationCompletionAction.setNavigation(
                        let viewControllers,
                        let previousViewControllers
                    ) = action
                    else { return }
                if number == 0 {
                    expect(viewControllers) == [firstViewController, secondViewController]
                    expect(previousViewControllers).to(beEmpty())
                    number += 1
                    call()
                } else if number == 2 {
                    expect(viewControllers).to(beEmpty())
                    expect(previousViewControllers) == [firstViewController]
                    number += 1
                    call()
                }
            case 1:
                guard
                    case NavigationCompletionAction.pop(
                        let viewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewController) === secondViewController
                expect(origin) == .code
                number += 1
                call()
            default: break
            }
        }
        navigationController.asRootOfKeyWindow()
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
        }
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController
                ],
                animated: false
            )
        }
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [],
                animated: false
            )
        }
    }
    
    func testSetViewControllersDispatchesPushCompletion() {
        var number = 0
        var call: (() -> Void)!
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let thirdViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            if number == 0,
                case NavigationCompletionAction.setNavigation(
                    let viewControllers,
                    let previousViewControllers
                ) = action {
                expect(viewControllers) == [firstViewController, secondViewController]
                expect(previousViewControllers).to(beEmpty())
                number += 1
                call()
            }
            if number == 1,
                case NavigationCompletionAction.push(
                    let viewController
                ) = action {
                expect(viewController) === thirdViewController
                number += 1
                call()
            }
        }
        navigationController.asRootOfKeyWindow()
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
        }
        waitUntil { done in
            call = done
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController,
                    thirdViewController
                ],
                animated: false
            )
        }
    }
    
    func testSetViewControllersDoesNotDispatchPushCompletionWhenEmpty() {
        waitUntil { done in
            let viewController = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.setNavigation(
                        let viewControllers,
                        let previousViewControllers
                    ) = action else { return }
                expect(viewControllers) == [viewController]
                expect(previousViewControllers).to(beEmpty())
                done()
            }
            navigationController
                .asRootOfKeyWindow()
                .setViewControllers(
                    [viewController],
                    animated: false
                )
        }
    }
    
}

extension NavigationControllerTests {
    
    func testPushDispatchesCompletion() {
        waitUntil { done in
            let viewControllerToPush = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.push(
                        let pushedViewController
                    ) = action
                    else { return }
                expect(viewControllerToPush) === pushedViewController
                done()
            }
            navigationController.setViewControllers(
                [
                    UIViewController(),
                    UIViewController()
                ],
                animated: false
            )
            navigationController.asRootOfKeyWindow().pushViewController(
                viewControllerToPush,
                animated: false
            )
        }
    }
    
}

extension NavigationControllerTests {
    
    func testPopToViewControllerDispatchesCompletion() {
        waitUntil { done in
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let fourthViewController = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.setNavigation(
                        let viewControllers,
                        let previousViewControllers
                    ) = action
                    else { return }
                expect(viewControllers) == [
                    firstViewController,
                    secondViewController
                ]
                expect(previousViewControllers) == [
                    firstViewController,
                    secondViewController,
                    thirdViewController,
                    fourthViewController
                ]
                done()
            }
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController,
                    thirdViewController,
                    fourthViewController
                ],
                animated: false
            )
            navigationController.asRootOfKeyWindow().popToViewController(
                secondViewController,
                animated: false
            )
        }
    }
    
    func testPopToViewControllerDoesNotDispatchCompletion() {
        var condition = false
        let firstViewController = UIViewController()
        let secondViewController = UIViewController()
        let navigationController = TestableNavigationController { action in
            switch action {
            case NavigationCompletionAction.setNavigation,
                 NavigationCompletionAction.pop:
                condition = true
            default: break
            }
        }
        navigationController.setViewControllers(
            [
                firstViewController,
                secondViewController
            ],
            animated: false
        )
        navigationController.asRootOfKeyWindow().popToViewController(
            secondViewController,
            animated: false
        )
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
    func testPopToViewControllerDispatchesPopCompletion() {
        waitUntil { done in
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let fourthViewController = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.pop(
                        let viewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewController) === fourthViewController
                expect(origin) == .code
                done()
            }
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController,
                    thirdViewController,
                    fourthViewController
                ],
                animated: false
            )
            navigationController.asRootOfKeyWindow().popToViewController(
                thirdViewController,
                animated: false
            )
        }
    }
    
}

extension NavigationControllerTests {
    
    func testPopToRootViewControllerDispatchesCompletion() {
        waitUntil { done in
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let fourthViewController = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.setNavigation(
                        let viewControllers,
                        let previousViewControllers
                    ) = action
                    else { return }
                expect(viewControllers) == [
                    firstViewController
                ]
                expect(previousViewControllers) == [
                    firstViewController,
                    secondViewController,
                    thirdViewController,
                    fourthViewController
                ]
                done()
            }
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController,
                    thirdViewController,
                    fourthViewController
                ],
                animated: false
            )
            navigationController
                .asRootOfKeyWindow()
                .popToRootViewController(animated: false)
        }
    }
    
    func testPopToRootViewControllerDoesNotDispatchCompletion() {
        var condition = false
        let navigationController = TestableNavigationController { action in
            switch action {
            case NavigationCompletionAction.setNavigation,
                 NavigationCompletionAction.pop:
                condition = true
            default: break
            }
        }
        navigationController.setViewControllers(
            [
                UIViewController()
            ],
            animated: false
        )
        navigationController
            .asRootOfKeyWindow()
            .popToRootViewController(animated: false)
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
    func testPopToRootViewControllerDispatchesPopCompletion() {
        waitUntil { done in
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.pop(
                        let viewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewController) === secondViewController
                expect(origin) == .code
                done()
            }
            navigationController.setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            navigationController
                .asRootOfKeyWindow()
                .popToRootViewController(animated: false)
        }
    }
    
}

extension NavigationControllerTests {
    
    func testProgrammaticallyPopDispatchesCompletion() {
        waitUntil { done in
            let viewControllerToPop = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.pop(
                        let poppedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewControllerToPop) === poppedViewController
                expect(origin) == .code
                done()
            }
            navigationController.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToPop
                ],
                animated: false
            )
            navigationController
                .asRootOfKeyWindow()
                .popViewController(
                    animated: false,
                    programmatically: ()
                )
        }
    }
    
    func testProgrammaticallyPopDoesNotDispatchCompletion() {
        var condition = false
        let navigationController = TestableNavigationController { action in
            switch action {
            case NavigationCompletionAction.pop:
                condition = true
            default: break
            }
        }
        navigationController.setViewControllers(
            [
                UIViewController()
            ],
            animated: false
        )
        navigationController
            .asRootOfKeyWindow()
            .popViewController(
                animated: false,
                programmatically: ()
            )
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
}

extension NavigationControllerTests {
    
    func testUserPopDispatchesCompletion() {
        waitUntil { done in
            let viewControllerToPop = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.pop(
                        let poppedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewControllerToPop) === poppedViewController
                expect(origin) == .user
                done()
            }
            navigationController.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToPop
                ],
                animated: false
            )
            navigationController
                .asRootOfKeyWindow()
                .popViewController(
                    animated: false
                )
        }
    }
    
    func testUserPopAfterSettingSameViewControllersDispatchesCompletion() {
        waitUntil { done in
            let viewControllerToPop = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.pop(
                        let poppedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewControllerToPop) === poppedViewController
                expect(origin) == .user
                done()
            }
            navigationController.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToPop
                ],
                animated: false
            )
            navigationController.asRootOfKeyWindow()
            navigationController.setViewControllers(
                navigationController.viewControllers,
                animated: false
            )
            navigationController.popViewController(
                animated: false
            )
        }
    }
    
    func testUserPopAfterPoppingToSameViewControllerDispatchesCompletion() {
        waitUntil { done in
            let viewControllerToPop = UIViewController()
            let navigationController = TestableNavigationController { action in
                guard
                    case NavigationCompletionAction.pop(
                        let poppedViewController,
                        let origin
                    ) = action
                    else { return }
                expect(viewControllerToPop) === poppedViewController
                expect(origin) == .user
                done()
            }
            navigationController.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToPop
                ],
                animated: false
            )
            navigationController.asRootOfKeyWindow()
            navigationController.popToViewController(
                viewControllerToPop,
                animated: false
            )
            navigationController.popViewController(
                animated: false
            )
        }
    }
    
}
