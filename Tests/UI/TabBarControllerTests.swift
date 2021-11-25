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
    
    func testSetViewControllersDispatchesCompletion() {
        waitUntil { done in
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            var tabBarController: UITabBarController!
            tabBarController = TestableTabBarController { action in
                guard
                    case NavigationCompletionAction.setTabs(
                        let viewControllers,
                        let previousViewControllers
                    ) = action
                    else { return }
                expect(previousViewControllers).to(beEmpty())
                expect(viewControllers) == [firstViewController, secondViewController]
                expect(tabBarController.viewControllers) == [firstViewController, secondViewController]
                done()
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 0
        }
    }
    
    func testSetViewControllersContainingSelectedViewControllerDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let fourthViewController = UIViewController()
            let tabBarController = TestableTabBarController { action in
                switch action {
                case NavigationCompletionAction.selectTab:
                    expect(number) == 1
                    number += 1
                case NavigationCompletionAction.setTabs(
                    let viewControllers,
                    let previousViewControllers
                    ):
                    if number == 0 {
                        number += 1
                    } else if number == 2 {
                        expect(previousViewControllers) == [
                            firstViewController,
                            secondViewController
                        ]
                        expect(viewControllers) == [
                            firstViewController,
                            thirdViewController,
                            fourthViewController,
                            secondViewController
                        ]
                        done()
                    }
                default: break
                }
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            tabBarController.selectedIndex = 1
            tabBarController.setViewControllers(
                [
                    firstViewController,
                    thirdViewController,
                    fourthViewController,
                    secondViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 3
        }
    }
    
    func testSetViewControllersWithoutContainingSelectedViewControllerDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let tabBarController = TestableTabBarController { action in
                switch action {
                case NavigationCompletionAction.selectTab(
                    _,
                    let index,
                    _,
                    _,
                    _
                    ):
                    if number == 1 {
                        expect(index) == 1
                    } else if number == 2 {
                        expect(index) == 0
                    } else {
                        fail()
                    }
                    number += 1
                case NavigationCompletionAction.setTabs(
                    let viewControllers,
                    let previousViewControllers
                    ):
                    if number == 0 {
                        expect(previousViewControllers).to(beEmpty())
                        expect(viewControllers) == [firstViewController, secondViewController]
                        number += 1
                    } else if number == 3 {
                        expect(previousViewControllers) == [firstViewController, secondViewController]
                        expect(viewControllers) == [thirdViewController]
                        done()
                    }
                default: break
                }
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            tabBarController.selectedIndex = 1
            tabBarController.setViewControllers(
                [
                    thirdViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 0
        }
    }
    
    func testSetViewControllersDoesNotDispatchCompletion() {
        var condition = false
        var call: (() -> Void)!
        let tabBarController = TestableTabBarController { action in
            switch action {
            case NavigationCompletionAction.setTabs,
                 NavigationCompletionAction.insertTab,
                 NavigationCompletionAction.removeTab:
                call()
            default: break
            }
        }
        waitUntil { done in
            call = done
            tabBarController.setViewControllers(
                [
                    UIViewController(),
                    UIViewController()
                ],
                animated: false
            )
        }
        call = {
            condition = true
        }
        tabBarController.setViewControllers(
            tabBarController.viewControllers ?? [],
            animated: false
        )
        expect(condition).toEventuallyNot(beTrue())
    }
    
    func testInsertViewControllerDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let tabBarController = TestableTabBarController { action in
                switch action {
                case NavigationCompletionAction.selectTab:
                    expect(number) == 1
                    number += 1
                case NavigationCompletionAction.setTabs:
                    expect(number) == 0
                    number += 1
                case NavigationCompletionAction.insertTab(
                    let viewController,
                    let index
                    ):
                    expect(viewController) === thirdViewController
                    expect(index) == 2
                    expect(number) == 2
                    done()
                default: break
                }
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            tabBarController.selectedIndex = 1
            tabBarController.setViewControllers(
                [
                    firstViewController,
                    secondViewController,
                    thirdViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 1
        }
    }
    
    func testInsertViewControllerAtZeroDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let thirdViewController = UIViewController()
            let tabBarController = TestableTabBarController { action in
                switch action {
                case NavigationCompletionAction.selectTab:
                    expect(number) == 1
                    number += 1
                case NavigationCompletionAction.setTabs:
                    expect(number) == 0
                    number += 1
                case NavigationCompletionAction.insertTab(
                    let viewController,
                    let index
                    ):
                    expect(viewController) === thirdViewController
                    expect(index) == 0
                    expect(number) == 2
                    done()
                default: break
                }
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            tabBarController.selectedIndex = 1
            tabBarController.setViewControllers(
                [
                    thirdViewController,
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 2
        }
    }
    
    func testRemoveViewControllerDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let tabBarController = TestableTabBarController { action in
                switch action {
                case NavigationCompletionAction.selectTab:
                    expect(number) == 1
                    number += 1
                case NavigationCompletionAction.setTabs:
                    expect(number) == 0
                    number += 1
                case NavigationCompletionAction.removeTab(
                    let viewController,
                    let index
                    ):
                    expect(viewController) === firstViewController
                    expect(index) == 0
                    expect(number) == 2
                    done()
                default: break
                }
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            tabBarController.selectedIndex = 1
            tabBarController.setViewControllers(
                [
                    secondViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 0
        }
    }
    
    func testRemoveSelectedViewControllerDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let firstViewController = UIViewController()
            let secondViewController = UIViewController()
            let tabBarController = TestableTabBarController { action in
                switch action {
                case NavigationCompletionAction.selectTab(
                    _,
                    let index,
                    _,
                    _,
                    _
                    ):
                    if number == 1 {
                        expect(index) == 1
                    } else if number == 2 {
                        expect(index) == 0
                    }
                    number += 1
                case NavigationCompletionAction.setTabs:
                    expect(number) == 0
                    number += 1
                case NavigationCompletionAction.removeTab(
                    let viewController,
                    let index
                    ):
                    expect(viewController) === secondViewController
                    expect(index) == 1
                    expect(number) == 3
                    done()
                default: break
                }
            }
            tabBarController.asRootOfKeyWindow().setViewControllers(
                [
                    firstViewController,
                    secondViewController
                ],
                animated: false
            )
            tabBarController.selectedIndex = 1
            tabBarController.setViewControllers(
                [
                    firstViewController
                ],
                animated: false
            )
            expect(tabBarController.selectedIndex) == 0
        }
    }
    
}

extension TabBarControllerTests {
    
    func testSetViewControllers() {
        let tabBarController = TabBarController()
        tabBarController.setViewControllers(
            [
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        expect(tabBarController.viewControllers?.count) == 2
    }
    
    func testSetViewControllersSetsEmpty() {
        let tabBarController = TabBarController()
        tabBarController.setViewControllers(
            [
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        expect(tabBarController.viewControllers?.count) == 2
        tabBarController.setViewControllers(
            [],
            animated: false
        )
        expect(tabBarController.viewControllers?.count) == 1
    }
    
    func testSetViewControllersRemovesEmpty() {
        let tabBarController = TabBarController()
        tabBarController.setViewControllers(
            [
                UIViewController(),
                UIViewController()
            ],
            animated: false
        )
        expect(tabBarController.viewControllers?.count) == 2
        tabBarController.setViewControllers(
            [],
            animated: false
        )
        expect(tabBarController.viewControllers?.count) == 1
        tabBarController.setViewControllers(
            [
                tabBarController.viewControllers![0],
                UIViewController()
            ],
            animated: false
        )
        expect(tabBarController.viewControllers?.count) == 1
    }
    
}

extension TabBarControllerTests {
    
    func testProgrammaticallySelectionDispatchesCompletion() {
        waitUntil { done in
            let tabBarController = TabBarController.toTestSelection(
                origin: .code,
                completion: done
            )
            tabBarController.selectedIndex = 1
        }
    }
    
    func testProgrammaticallySameSelectionDoesNotDispatchCompletion() {
        var condition = false
        var call: (() -> Void)!
        let tabBarController = TabBarController.toTestSelection(
            origin: .user
        ) {
            call()
        }
        waitUntil { done in
            call = done
            tabBarController.selectedIndex = 1
        }
        call = {
            condition = true
        }
        tabBarController.selectedIndex = 1
        expect(condition).toEventuallyNot(beTrue())
    }
    
    func testProgrammaticallySelectionDoesNotDispatchAction() {
        var condition = false
        let tabBarController = TabBarController.toTestSelection(
            origin: .user
        ) {
            condition = true
        }
        tabBarController.selectedIndex = 10
        expect(condition).toEventuallyNot(beTrue())
    }
    
    func testProgrammaticallySelectionAfterNotSelectionDispatchesAction() {
        waitUntil { done in
            let tabBarController = TabBarController.toTestSelection(
                origin: .user,
                completion: done
            )
            tabBarController.selectedIndex = 10
            tabBarController.selectedIndex = 1
        }
    }
    
}

extension TabBarControllerTests {
    
    func testUserSelectionDispatchesCompletion() {
        waitUntil { done in
            let tabBarController = TabBarController.toTestSelection(
                origin: .user,
                completion: done
            )
            tabBarController.callDidSelectDelegate(
                with: tabBarController.viewControllers?[1]
            )
        }
    }
    
    func testUserSameSelectionDispatchesCompletion() {
        waitUntil { done in
            var number = 0
            let tabBarController = TabBarController.toTestSelection(
                origin: .user,
                sameThanPrevious: { number == 1 }
            ) {
                if number == 1 {
                    done()
                }
                number += 1
            }
            tabBarController.callDidSelectDelegate(
                with: tabBarController.viewControllers?[1]
            )
            tabBarController.callDidSelectDelegate(
                with: tabBarController.viewControllers?[1]
            )
        }
    }
    
}

private extension TabBarController {
    
    static func toTestSelection(
        origin: NavigationCompletionActionOrigin,
        sameThanPrevious: @escaping () -> Bool = { false },
        completion: @escaping () -> Void
    ) -> TabBarController {
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
            expect(previousViewController) === viewControllers[sameThanPrevious() ? 1 : 0]
            expect(viewController) === viewControllers[1]
            expect(origin) == origin
            completion()
        }
        tabBarController.asRootOfKeyWindow().setViewControllers(
            viewControllers,
            animated: false
        )
        return tabBarController
    }
    
    func callDidSelectDelegate(
        with viewController: UIViewController?
    ) {
        guard let viewController = viewController else {
            fail()
            return
        }
        expect(
            self.delegate?.tabBarController?(
                self,
                shouldSelect: viewController
            )
        ).to(
            beTrue()
        )
        selectedViewController = viewController
        delegate?.tabBarController?(
            self,
            didSelect: viewController
        )
    }
    
}
