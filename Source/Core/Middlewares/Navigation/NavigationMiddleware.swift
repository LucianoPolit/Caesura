//
//  NavigationMiddleware.swift
//
//  Copyright (c) 2020 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

class NavigationMiddleware: Middleware {
    
    let window = UIWindow()
    
    func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                guard let navigationAction = action as? NavigationAction else {
                    next(action)
                    return
                }
                self.handle(
                    action: navigationAction,
                    dispatch: dispatch
                )
            }
        }
    }
    
}

private extension NavigationMiddleware {
    
    func handle(
        action: NavigationAction,
        dispatch: DispatchFunction
    ) {
        switch action {
        case .start:
            dispatch(
                NavigationCompletionAction.start(window)
            )
        case .set, .present, .dismiss,
             .dismissToViewController, .dismissToRootViewController:
            handlePresentationAction(
                action,
                dispatch: dispatch
            )
        case .setNavigation, .push, .pop,
             .popToViewController, .popToRootViewController:
            handleNavigationAction(
                action,
                dispatch: dispatch
            )
        case .setTabs, .insertTab, .removeTab,
             .selectTab, .selectTabAtIndex:
            handleTabAction(
                action,
                dispatch: dispatch
            )
        }
    }
    
}

private extension NavigationMiddleware {
    
    func handlePresentationAction(
        _ action: NavigationAction,
        dispatch: DispatchFunction
    ) {
        switch action {
        case .start,
             .setNavigation, .push, .pop,
             .popToViewController, .popToRootViewController,
             .setTabs, .insertTab, .removeTab,
             .selectTab, .selectTabAtIndex:
            break
        case .set(let viewController):
            let previousViewController = window.rootViewController
            window.rootViewController = viewController
            if !window.isKeyWindow {
                window.makeKeyAndVisible()
            }
            dispatch(
                NavigationCompletionAction.set(
                    viewController,
                    previous: previousViewController
                )
            )
        case .present(let viewController, let animated):
            topViewController?.present(
                viewController,
                animated: animated
            )
        case .dismiss(let amount, let animated):
            guard let viewController = topViewController?
                .presentingViewController(skipping: amount) else { return }
            handlePresentationAction(
                .dismissToViewController(
                    viewController,
                    animated: animated
                ),
                dispatch: dispatch
            )
        case .dismissToViewController(let viewController, let animated):
            guard viewController.topViewController == topViewController,
                viewController.presentedViewController != nil
                else { return }
            viewController.dismiss(
                animated: animated,
                programmatically: ()
            )
        case .dismissToRootViewController(let animated):
            guard let viewController = window.rootViewController else { return }
            handlePresentationAction(
                .dismissToViewController(
                    viewController,
                    animated: animated
                ),
                dispatch: dispatch
            )
        }
    }
    
}
    
private extension NavigationMiddleware {
    
    func handleNavigationAction(
        _ action: NavigationAction,
        dispatch: DispatchFunction
    ) {
        switch action {
        case .start,
             .set, .present, .dismiss,
             .dismissToViewController, .dismissToRootViewController,
             .setTabs, .insertTab, .removeTab,
             .selectTab, .selectTabAtIndex:
            break
        case .setNavigation(let viewControllers, let animated):
            topNavigationController?.setViewControllers(
                viewControllers,
                animated: animated
            )
        case .push(let viewController, let animated):
            topNavigationController?.pushViewController(
                viewController,
                animated: animated
            )
        case .pop(let amount, let animated):
            guard let viewControllers = topNavigationController?.viewControllers,
                let viewController = viewControllers[safe: viewControllers.count - amount - 1]
                else {
                    handleNavigationAction(
                        .popToRootViewController(
                            animated: animated
                        ),
                        dispatch: dispatch
                    )
                    return
                }
            handleNavigationAction(
                .popToViewController(
                    viewController,
                    animated: animated
                ),
                dispatch: dispatch
            )
        case .popToViewController(let viewController, let animated):
            topNavigationController?.popToViewController(
                viewController,
                animated: animated
            )
        case .popToRootViewController(let animated):
            topNavigationController?.popToRootViewController(
                animated: animated
            )
        }
    }
    
}

private extension NavigationMiddleware {
    
    func handleTabAction(
        _ action: NavigationAction,
        dispatch: DispatchFunction
    ) {
        guard let topTabBarController = topTabBarController else { return }
        let viewControllers = topTabBarController.viewControllers ?? []
        
        switch action {
        case .start,
             .set, .present, .dismiss,
             .dismissToViewController, .dismissToRootViewController,
             .setNavigation, .push, .pop,
             .popToViewController, .popToRootViewController:
            break
        case .setTabs(let viewControllers, let animated):
            topTabBarController.setViewControllers(
                viewControllers,
                animated: animated
            )
        case .insertTab(let viewController, let insertionOrder, let animated):
            let index = insertionOrder.value(
                from: topTabBarController
            )
            guard index >= 0 && index <= viewControllers.count else { return }
            topTabBarController.setViewControllers(
                viewControllers.with {
                    $0.insert(viewController, at: index)
                },
                animated: animated
            )
        case .removeTab(let viewController, let animated):
            guard let index = viewControllers.firstIndex(of: viewController) else { return }
            topTabBarController.setViewControllers(
                viewControllers.with {
                    $0.remove(at: index)
                },
                animated: animated
            )
        case .selectTab(let viewController, let animated):
            guard let index = viewControllers.firstIndex(of: viewController) else { return }
            handleTabAction(
                .selectTabAtIndex(
                    index,
                    animated: animated
                ),
                dispatch: dispatch
            )
        case .selectTabAtIndex(let index, _):
            topTabBarController.selectedIndex = index
        }
    }
    
}

private extension NavigationMiddleware {
    
    var topViewController: UIViewController? {
        return window.rootViewController?.topViewController
    }
    
    var topNavigationController: UINavigationController? {
        return topViewController?.navigationController
    }
    
    var topTabBarController: UITabBarController? {
        return topViewController as? UITabBarController ??
            topNavigationController?.tabBarController ??
            topViewController?.tabBarController
    }
    
}

private extension UIViewController {
    
    var topViewController: UIViewController {
        let viewController = presentedViewController ?? self
        switch viewController {
        case let navigationController as UINavigationController:
            return (navigationController.viewControllers.last ?? navigationController).topViewController
        case let tabBarController as UITabBarController:
            return tabBarController.selectedViewController?.topViewController ?? tabBarController
        default:
            return viewController
        }
    }
    
}

private extension UIViewController {
    
    func presentingViewController(
        skipping amountToSkip: Int,
        defaultToRoot: Bool = true
    ) -> UIViewController? {
        if amountToSkip <= 0 || (defaultToRoot && presentingViewController == nil) { return self }
        return presentingViewController?
            .presentingViewController(skipping: amountToSkip - 1)
    }
    
}

private extension UIViewController {
    
    func dismiss(
        animated flag: Bool,
        programmatically: Void
    ) {
        if let viewController = self as? CanDismissProgrammatically {
            viewController.dismiss(
                animated: flag,
                completion: nil,
                programmatically: ()
            )
        } else {
            dismiss(
                animated: flag
            )
        }
    }
    
}

private extension UINavigationController {
    
    @discardableResult
    func popViewController(
        animated: Bool,
        programmatically: Void
    ) -> UIViewController? {
        if let navigationController = self as? CanPopProgrammatically {
            return navigationController.popViewController(
                animated: animated,
                programmatically: ()
            )
        } else {
            return popViewController(
                animated: animated
            )
        }
    }
    
}

private extension TabItemInsertionOrder {
    
    func value(
        from tabBarController: UITabBarController
    ) -> Int {
        switch self {
        case .first: return 0
        case .index(let index): return index
        case .last: return tabBarController.viewControllers?.count ?? 0
        }
    }
    
}
