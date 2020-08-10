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
           guard navigationController == nil else { return }
           dismissHandler.listen()
       }
    
}

extension TabBarController: UITabBarControllerDelegate {
    
    open func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController),
            let selectedViewController = selectedViewController
            else { return true }
        defer {
            manager.store.dispatch(
                NavigationCompletionAction.selectTab(
                    viewController,
                    at: index,
                    previous: selectedViewController,
                    previousIndex: selectedIndex,
                    origin: .user
                )
            )
        }
        return true
    }
    
}
