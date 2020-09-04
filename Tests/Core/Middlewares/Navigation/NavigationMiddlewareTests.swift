//
//  NavigationMiddlewareTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class NavigationMiddlewareTests: TestCase {
    
    let middleware = NavigationMiddleware()
    
}

extension NavigationMiddlewareTests {
    
    func testCallsNextWhenNotANavigationAction() {
        var condition = false
        middleware.testIntercept(
            withAction: TestAction.start,
            next: {
                guard case TestAction.start = $0 else { return fail() }
                condition = true
            }
        )
        expect(condition).to(beTrue())
    }
    
}

extension NavigationMiddlewareTests {
    
    func testStart() {
        var condition = false
        middleware.testIntercept(
            withAction: NavigationAction.start,
            dispatch: {
                guard case NavigationCompletionAction.start(let window) = $0 else { return fail() }
                expect(window.isKeyWindow).to(beFalse())
                expect(window.isHidden).to(beTrue())
                expect(window.rootViewController).to(beNil())
                condition = true
            }
        )
        expect(condition).to(beTrue())
    }
    
}

extension NavigationMiddlewareTests {
    
    func testSet() {
        var number = 0
        var window: UIWindow?
        let viewController = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController)
            ],
            dispatch: {
                switch number {
                case 0:
                    guard case NavigationCompletionAction.start(let startedWindow) = $0 else { return fail() }
                    window = startedWindow
                case 1:
                    guard case NavigationCompletionAction.set = $0 else { return fail() }
                    expect(window?.isKeyWindow).to(beTrue())
                    expect(window?.isHidden).to(beFalse())
                    expect(window?.rootViewController) === viewController
                default:
                    fail()
                }
                number += 1
            }
        )
        expect(number) == 2
    }
    
    func testPresent() {
        let viewController = MockViewController()
        let viewControllerToPresent = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(viewControllerToPresent)
            ],
            dispatch: { _ in }
        )
        expect(viewController.presentCalled).to(beTrue())
        expect(viewController.presentParameters?.0) === viewControllerToPresent
        expect(viewController.presentParameters?.1).to(beTrue())
        expect(viewController.presentParameters?.2).to(beNil())
    }
    
    func testPresentWithoutAnimation() {
        let viewController = MockViewController()
        let viewControllerToPresent = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(viewControllerToPresent, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(viewController.presentCalled).to(beTrue())
        expect(viewController.presentParameters?.0) === viewControllerToPresent
        expect(viewController.presentParameters?.1).to(beFalse())
        expect(viewController.presentParameters?.2).to(beNil())
    }
    
    func testPresentFromNavigationController() {
        let viewController = MockViewController()
        let navigationController = UINavigationController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    viewController
                ],
                animated: false
            )
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.present(UIViewController())
            ],
            dispatch: { _ in }
        )
        expect(viewController.presentCalled).to(beTrue())
    }
    
    func testPresentFromTabBarController() {
        let viewController = MockViewController()
        let navigationController = TabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    viewController
                ],
                animated: false
            )
            $0.selectedIndex = 1
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.present(UIViewController())
            ],
            dispatch: { _ in }
        )
        expect(viewController.presentCalled).to(beTrue())
    }
    
    func testDismiss() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismiss()
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beTrue())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissMoreThanOneViewController() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismiss(2)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beTrue())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissMoreThanOneViewControllerWithAHigherNumber() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismiss(10)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beTrue())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissToViewController() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismissToViewController(viewController)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beTrue())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissToViewControllerWithoutAnimation() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismissToViewController(viewController, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beFalse())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissToViewControllerWhenRootViewController() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.dismissToViewController(viewController)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beFalse())
        expect(viewController.dismissParameters?.0).to(beNil())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissToViewControllerWhenTopViewController() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(UIViewController()),
                NavigationAction.present(viewController),
                NavigationAction.dismissToViewController(viewController)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beFalse())
        expect(viewController.dismissParameters?.0).to(beNil())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissToRootViewController() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismissToRootViewController()
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beTrue())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissToRootViewControllerWithoutAnimation() {
        let viewController = MockViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismissToRootViewController(animated: false)
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beTrue())
        expect(viewController.dismissParameters?.0).to(beFalse())
        expect(viewController.dismissParameters?.1).to(beNil())
    }
    
    func testDismissCallsProgrammaticallyWhenPossible() {
        let viewController = ProgrammaticallyDismissableViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(viewController),
                NavigationAction.present(UIViewController()),
                NavigationAction.present(UIViewController()),
                NavigationAction.dismissToRootViewController()
            ],
            dispatch: { _ in }
        )
        expect(viewController.dismissCalled).to(beFalse())
        expect(viewController.dismissParameters?.0).to(beNil())
        expect(viewController.dismissParameters?.1).to(beNil())
        expect(viewController.programmaticallyDismissCalled).to(beTrue())
        expect(viewController.programmaticallyDismissParameters?.0).to(beTrue())
        expect(viewController.programmaticallyDismissParameters?.1).to(beNil())
    }
    
}

extension NavigationMiddlewareTests {
    
    func testSetNavigation() {
        let navigationController = MockNavigationController()
        let viewControllers = [UIViewController()]
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.setNavigation(to: viewControllers)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.setViewControllersCalled).to(beTrue())
        expect(navigationController.setViewControllersParameters?.0) == viewControllers
        expect(navigationController.setViewControllersParameters?.1).to(beTrue())
    }
    
    func testSetNavigationWithoutAnimation() {
        let navigationController = MockNavigationController()
        let viewControllers = [UIViewController()]
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.setNavigation(to: viewControllers, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.setViewControllersCalled).to(beTrue())
        expect(navigationController.setViewControllersParameters?.0) == viewControllers
        expect(navigationController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testPush() {
        let navigationController = MockNavigationController(
            rootViewController: UIViewController()
        )
        let viewControllerToPush = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.push(viewControllerToPush)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.pushViewControllerCalled).to(beTrue())
        expect(navigationController.pushViewControllerParamaters?.0) === viewControllerToPush
        expect(navigationController.pushViewControllerParamaters?.1).to(beTrue())
    }
    
    func testPushWithoutAnimation() {
        let navigationController = MockNavigationController()
        let viewControllerToPush = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.push(viewControllerToPush, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.pushViewControllerCalled).to(beTrue())
        expect(navigationController.pushViewControllerParamaters?.0) === viewControllerToPush
        expect(navigationController.pushViewControllerParamaters?.1).to(beFalse())
    }
    
    func testPopToViewController() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.popToViewController(destinationViewController)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popToViewControllerCalled).to(beTrue())
        expect(navigationController.popToViewControllerParamaters?.0) === destinationViewController
        expect(navigationController.popToViewControllerParamaters?.1).to(beTrue())
    }
    
    func testPopToViewControllerWithoutAnimation() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.popToViewController(destinationViewController, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popToViewControllerCalled).to(beTrue())
        expect(navigationController.popToViewControllerParamaters?.0) === destinationViewController
        expect(navigationController.popToViewControllerParamaters?.1).to(beFalse())
    }
    
    func testPopToRootViewController() {
        let navigationController = MockNavigationController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.popToRootViewController()
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popToRootViewControllerCalled).to(beTrue())
        expect(navigationController.popToRootViewControllerParamaters).to(beTrue())
    }
    
    func testPopToRootViewControllerWithoutAnimation() {
        let navigationController = MockNavigationController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.popToRootViewController(animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popToRootViewControllerCalled).to(beTrue())
        expect(navigationController.popToRootViewControllerParamaters).to(beFalse())
    }
    
    func testPopAsPopToViewController() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        navigationController.setViewControllers(
            [
                destinationViewController,
                UIViewController()
            ],
            animated: false
        )
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.pop()
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popViewControllerCalled).to(beFalse())
        expect(navigationController.popToViewControllerCalled).to(beTrue())
        expect(navigationController.popToViewControllerParamaters?.0) === destinationViewController
        expect(navigationController.popToViewControllerParamaters?.1).to(beTrue())
    }
    
    func testPopAsPopToViewControllerWithoutAnimation() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        navigationController.setViewControllers(
            [
                destinationViewController,
                UIViewController()
            ],
            animated: false
        )
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.pop(animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popViewControllerCalled).to(beFalse())
        expect(navigationController.popToViewControllerCalled).to(beTrue())
        expect(navigationController.popToViewControllerParamaters?.0) === destinationViewController
        expect(navigationController.popToViewControllerParamaters?.1).to(beFalse())
    }
    
    func testPopMoreThanOneAsPopToViewController() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        navigationController.setViewControllers(
            [
                destinationViewController,
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.pop(2)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popViewControllerCalled).to(beFalse())
        expect(navigationController.popToViewControllerCalled).to(beTrue())
        expect(navigationController.popToViewControllerParamaters?.0) === destinationViewController
        expect(navigationController.popToViewControllerParamaters?.1).to(beTrue())
    }
    
    func testPopMoreThanOneAsPopToViewControllerWithoutAnimation() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        navigationController.setViewControllers(
            [
                destinationViewController,
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.pop(2, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popViewControllerCalled).to(beFalse())
        expect(navigationController.popToViewControllerCalled).to(beTrue())
        expect(navigationController.popToViewControllerParamaters?.0) === destinationViewController
        expect(navigationController.popToViewControllerParamaters?.1).to(beFalse())
    }
    
    func testPopAsPopToRootViewController() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        navigationController.setViewControllers(
            [
                destinationViewController,
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.pop(3)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popViewControllerCalled).to(beFalse())
        expect(navigationController.popToViewControllerCalled).to(beFalse())
        expect(navigationController.popToRootViewControllerCalled).to(beTrue())
        expect(navigationController.popToRootViewControllerParamaters).to(beTrue())
    }
    
    func testPopAsPopToRootViewControllerWithoutAnimation() {
        let navigationController = MockNavigationController()
        let destinationViewController = UIViewController()
        navigationController.setViewControllers(
            [
                destinationViewController,
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(navigationController),
                NavigationAction.pop(3, animated: false)
            ],
            dispatch: { _ in }
        )
        expect(navigationController.popViewControllerCalled).to(beFalse())
        expect(navigationController.popToViewControllerCalled).to(beFalse())
        expect(navigationController.popToRootViewControllerCalled).to(beTrue())
        expect(navigationController.popToRootViewControllerParamaters).to(beFalse())
    }
    
}

extension NavigationMiddlewareTests {
    
    func testSetTabs() {
        let tabBarController = MockTabBarController()
        let viewControllers = [UIViewController()]
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.setTabs(viewControllers)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0) == viewControllers
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testSetTabsAnimated() {
        let tabBarController = MockTabBarController()
        let viewControllers = [UIViewController()]
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.setTabs(viewControllers, animated: true)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0) == viewControllers
        expect(tabBarController.setViewControllersParameters?.1).to(beTrue())
    }
    
    func testInsertTabAtLast() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [UIViewController(), UIViewController()],
                animated: false
            )
        }
        let viewControllerToBeInserted = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.insertTab(viewControllerToBeInserted)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0?.last) === viewControllerToBeInserted
        expect(tabBarController.setViewControllersParameters?.0?.count) == 3
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testInsertTabAtIndex() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [UIViewController(), UIViewController()],
                animated: false
            )
        }
        let viewControllerToBeInserted = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.insertTab(viewControllerToBeInserted, at: .index(1))
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0?[safe: 1]) === viewControllerToBeInserted
        expect(tabBarController.setViewControllersParameters?.0?.count) == 3
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testInsertTabAtLastIndex() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [UIViewController(), UIViewController()],
                animated: false
            )
        }
        let viewControllerToBeInserted = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.insertTab(viewControllerToBeInserted, at: .index(2))
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0?.last) === viewControllerToBeInserted
        expect(tabBarController.setViewControllersParameters?.0?.count) == 3
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testInsertTabAtFirst() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [UIViewController(), UIViewController()],
                animated: false
            )
        }
        let viewControllerToBeInserted = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.insertTab(viewControllerToBeInserted, at: .first)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0?.first) === viewControllerToBeInserted
        expect(tabBarController.setViewControllersParameters?.0?.count) == 3
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testInsertTabAnimated() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [UIViewController(), UIViewController()],
                animated: false
            )
        }
        let viewControllerToBeInserted = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.insertTab(viewControllerToBeInserted, animated: true)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0?.last) === viewControllerToBeInserted
        expect(tabBarController.setViewControllersParameters?.0?.count) == 3
        expect(tabBarController.setViewControllersParameters?.1).to(beTrue())
    }
    
    func testInsertTabOutOfIndex() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [UIViewController(), UIViewController()],
                animated: false
            )
            $0.setViewControllersCalled = false
        }
        let viewControllerToBeInserted = UIViewController()
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.insertTab(viewControllerToBeInserted, at: .index(10))
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beFalse())
        expect(tabBarController.setViewControllersParameters?.0).toNot(contain(viewControllerToBeInserted))
        expect(tabBarController.setViewControllersParameters?.0?.count) == 2
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testRemoveTab() {
        let viewControllerToBeRemoved = UIViewController()
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToBeRemoved
                ],
                animated: false
            )
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.removeTab(viewControllerToBeRemoved)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0).toNot(contain(viewControllerToBeRemoved))
        expect(tabBarController.setViewControllersParameters?.1).to(beFalse())
    }
    
    func testRemoveTabAnimated() {
        let viewControllerToBeRemoved = UIViewController()
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToBeRemoved
                ],
                animated: false
            )
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.removeTab(viewControllerToBeRemoved, animated: true)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beTrue())
        expect(tabBarController.setViewControllersParameters?.0).toNot(contain(viewControllerToBeRemoved))
        expect(tabBarController.setViewControllersParameters?.1).to(beTrue())
    }
    
    func testRemoveUnknownTab() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController()
                ],
                animated: false
            )
            $0.setViewControllersCalled = false
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.removeTab(UIViewController())
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.setViewControllersCalled).to(beFalse())
    }
    
    func testSelectTab() {
        let viewControllerToBeSelected = UIViewController()
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    viewControllerToBeSelected
                ],
                animated: false
            )
            $0.setViewControllersCalled = false
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.selectTab(viewControllerToBeSelected)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.selectedIndex) == 1
    }
    
    func testSelectUnknownTab() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    UIViewController()
                ],
                animated: false
            )
            $0.setViewControllersCalled = false
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.selectTab(UIViewController())
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.selectedIndex) == 0
    }
    
    func testSelectTabByIndex() {
        let tabBarController = MockTabBarController().with {
            $0.setViewControllers(
                [
                    UIViewController(),
                    UIViewController()
                ],
                animated: false
            )
            $0.setViewControllersCalled = false
        }
        middleware.testIntercept(
            withActions: [
                NavigationAction.start,
                NavigationAction.set(tabBarController),
                NavigationAction.selectTabAtIndex(1)
            ],
            dispatch: { _ in }
        )
        expect(tabBarController.selectedIndex) == 1
    }
    
}

private class ProgrammaticallyDismissableViewController: MockViewController, CanDismissProgrammatically {
    
    var programmaticallyDismissCalled = false
    var programmaticallyDismissParameters: (Bool, (() -> Void)?)?
    func dismiss(
        animated flag: Bool,
        completion: (() -> Void)? = nil,
        programmatically: Void
    ) {
        programmaticallyDismissCalled = true
        programmaticallyDismissParameters = (
            flag,
            completion
        )
    }
    
}
