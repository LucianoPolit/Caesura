//
//  TabBarController.swift
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

open class TabBarController: UITabBarController, HasDismissHandler, CanDismissProgrammatically {
    
    private var origin: NavigationCompletionActionOrigin = .user
    private weak var previousSelectedViewController: UIViewController?
    
    open lazy var dismissHandler = DismissHandler(
        viewController: self,
        manager: manager
    )
    open var manager: Manager {
        return .main
    }
    
    open override var selectedIndex: Int {
        willSet {
            previousSelectedViewController =
                viewController(at: selectedIndex)
                ?? previousSelectedViewController
        }
        didSet {
            guard let viewController = viewController(at: selectedIndex),
                selectedIndex != oldValue,
                oldValue != .max
                else { return }
            origin = .code
            tabBarController(
                self,
                didSelect: viewController
            )
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    open override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        guard navigationController == nil else { return }
        dismissHandler.listen()
    }
    
    open override func setViewControllers(
        _ viewControllers: [UIViewController]?,
        animated: Bool
    ) {
        let callSuper = {
            super.setViewControllers(
                {
                    guard var viewControllers = viewControllers else { return nil }
                    if viewControllers.isEmpty {
                        viewControllers = [.empty]
                    }
                    if let index = viewControllers.firstIndex(of: .empty),
                        viewControllers.count > 1 {
                        viewControllers.remove(at: index)
                    }
                    return viewControllers
                }(),
                animated: animated
            )
        }
        
        guard let viewControllers = viewControllers,
            !viewControllers.isEmpty || self.viewControllers != nil,
            viewControllers != self.viewControllers
            else { return callSuper() }
        
        if let selectedViewController = selectedViewController,
            viewControllers.firstIndex(
                of: selectedViewController
            ) == nil {
            selectedIndex = 0
        }
        
        let previousViewControllers = self.viewControllers ?? []
        let insertedViewControllers = viewControllers.filter {
            !previousViewControllers.contains($0)
        }
        let removedViewControllers = previousViewControllers.filter {
            !viewControllers.contains($0)
        }
        
        defer {
            if insertedViewControllers.count == 1,
                removedViewControllers.isEmpty,
                let index = viewControllers.firstIndex(
                    of: insertedViewControllers[0]
                ) {
                manager.store.dispatch(
                    NavigationCompletionAction.insertTab(
                        insertedViewControllers[0],
                        at: index
                    )
                )
            } else if removedViewControllers.count == 1,
                insertedViewControllers.isEmpty,
                let index = previousViewControllers.firstIndex(
                    of: removedViewControllers[0]
                ) {
                manager.store.dispatch(
                    NavigationCompletionAction.removeTab(
                        removedViewControllers[0],
                        at: index
                    )
                )
            } else {
                manager.store.dispatch(
                    NavigationCompletionAction.setTabs(
                        viewControllers,
                        previous: previousViewControllers
                    )
                )
            }
        }
        
        callSuper()
    }
    
}

extension TabBarController: UITabBarControllerDelegate {
    
    public func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        previousSelectedViewController = selectedViewController
        return true
    }
    
    open func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        defer { origin = .user }
        guard let index = viewControllers?.firstIndex(of: viewController),
            let previousSelectedViewController = previousSelectedViewController
            else { return }
        manager.store.dispatch(
            NavigationCompletionAction.selectTab(
                viewController,
                at: index,
                previous: previousSelectedViewController,
                previousIndex: selectedIndex,
                origin: origin
            )
        )
    }
    
}

private extension TabBarController {
    
    func viewController(at index: Int) -> UIViewController? {
        guard let viewControllers = viewControllers else { return nil }
        return viewControllers.indices.contains(index) ? viewControllers[index] : nil
    }
    
}

private extension UIViewController {
    
    static let empty = UIViewController()
    
}
