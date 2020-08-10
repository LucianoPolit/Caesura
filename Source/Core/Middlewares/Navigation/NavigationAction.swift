//
//  NavigationAction.swift
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

public enum TabItemInsertionOrder {
    case first
    case index(Int)
    case last
}

public enum NavigationAction: Action {
    case start
    
    case set(UIViewController?)
    case present(UIViewController, animated: Bool = true)
    case dismiss(Int = 1, animated: Bool = true)
    case dismissToViewController(UIViewController, animated: Bool = true)
    case dismissToRootViewController(animated: Bool = true)
    
    case setNavigation(to: [UIViewController], animated: Bool = true)
    case push(UIViewController, animated: Bool = true)
    case pop(Int = 1, animated: Bool = true)
    case popToViewController(UIViewController, animated: Bool = true)
    case popToRootViewController(animated: Bool = true)
    
    case setTabs([UIViewController], animated: Bool = false)
    case insertTab(UIViewController, at: TabItemInsertionOrder = .last, animated: Bool = false)
    case removeTab(UIViewController, animated: Bool = false)
    case selectTab(UIViewController, animated: Bool = false)
    case selectTabAtIndex(Int, animated: Bool = false)
}

public enum NavigationCompletionActionOrigin {
    case code
    case user
}

public enum NavigationCompletionAction: Action {
    case start(UIWindow)
    
    case set(UIViewController?, previous: UIViewController?)
    case present(UIViewController)
    case dismiss(UIViewController, origin: NavigationCompletionActionOrigin)
    
    case setNavigation(to: [UIViewController], previous: [UIViewController])
    case push(UIViewController)
    case pop(UIViewController, origin: NavigationCompletionActionOrigin)
    
    case setTabs([UIViewController], previous: [UIViewController])
    case insertTab(UIViewController, at: Int)
    case removeTab(UIViewController, at: Int)
    case selectTab(
        UIViewController,
        at: Int,
        previous: UIViewController,
        previousIndex: Int,
        origin: NavigationCompletionActionOrigin
    )
}
