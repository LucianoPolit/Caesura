//
//  NavigationController.swift
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
#if !COCOAPODS
import Caesura
#endif

open class NavigationController: UINavigationController, HasDismissHandler, CanDismissProgrammatically {
    
    private var origin: NavigationCompletionActionOrigin = .user
    private var shownViewControllers: [UIViewController] = []
    
    open lazy var dismissHandler = DismissHandler(
        viewController: self,
        manager: manager
    )
    open var manager: Manager {
        return .main
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    open override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        origin = .user
        shownViewControllers = viewControllers
        guard tabBarController == nil else { return }
        dismissHandler.listen()
    }
    
    open override func setViewControllers(
        _ viewControllers: [UIViewController],
        animated: Bool
    ) {
        defer {
            super.setViewControllers(
                viewControllers,
                animated: animated
            )
        }
        
        guard !viewControllers.isEmpty,
            viewControllers != self.viewControllers
            else { return }

        if viewControllers.last == self.viewControllers.last {
            manager.store.dispatch(
                NavigationCompletionAction.setNavigation(
                    to: viewControllers,
                    previous: shownViewControllers
                )
            )
        } else {
            origin = .code
        }
    }
    
    @discardableResult
    open override func popToViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        let viewControllers = super.popToViewController(
            viewController,
            animated: animated
        )
        if viewControllers != nil {
            origin = .code
        }
        return viewControllers
    }
    
    @discardableResult
    open override func popToRootViewController(
        animated: Bool
    ) -> [UIViewController]? {
        let viewControllers = super.popToRootViewController(
            animated: animated
        )
        if viewControllers != nil {
            origin = .code
        }
        return viewControllers
    }
    
}

extension NavigationController: CanPopProgrammatically {
    
    @discardableResult
    public func popViewController(
        animated: Bool,
        programmatically: Void
    ) -> UIViewController? {
        let viewController = popViewController(
            animated: animated
        )
        if viewController != nil {
            origin = .code
        }
        return viewController
    }
    
}

extension NavigationController: UINavigationControllerDelegate {
    
    open func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard shownViewControllers != viewControllers else { return }
        let dispatch = { (action: NavigationCompletionAction) in
            self.origin = .user
            self.shownViewControllers = self.viewControllers
            self.manager.store.dispatch(action)
        }
        
        if !shownViewControllers.isEmpty,
            shownViewControllers.count == viewControllers.count - 1,
            shownViewControllers == Array(viewControllers[0 ..< viewControllers.count - 1]),
            let pushedViewController = viewControllers.last {
            dispatch(
                NavigationCompletionAction.push(
                    pushedViewController
                )
            )
        } else if !viewControllers.isEmpty,
            shownViewControllers.count == viewControllers.count + 1,
            Array(shownViewControllers[0 ..< shownViewControllers.count - 1]) == viewControllers,
            let lastViewController = shownViewControllers.last {
            dispatch(
                NavigationCompletionAction.pop(
                    lastViewController,
                    origin: origin
                )
            )
        } else {
            dispatch(
                NavigationCompletionAction.setNavigation(
                    to: viewControllers,
                    previous: shownViewControllers
                )
            )
        }
    }
    
}
