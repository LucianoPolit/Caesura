//
//  DismissHandler.swift
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

public protocol HasDismissHandler: class {
    var dismissHandler: DismissHandler { get }
}

public class DismissHandler: NSObject {
    
    public private(set) weak var viewController: UIViewController?
    public let manager: Manager
    
    public init(
        viewController: UIViewController,
        manager: Manager
    ) {
        self.viewController = viewController
        self.manager = manager
    }
    
    public func listen() {
        viewController?.presentationController?.delegate = self
    }
    
    public func handle(
        _ dismiss: ((() -> Void)?) -> Void,
        completion: (() -> Void)?
    ) {
        guard let viewController = viewController else { return }
        let presentedViewControllers =
            (viewController.responsibleViewController.presentedViewControllers()
                ?? [viewController.responsibleViewController])
                .filter { $0.presentingViewController != nil }
                .reversed()
        dismiss { [weak self] in
            presentedViewControllers.forEach {
                self?.manager.store.dispatch(
                    NavigationCompletionAction.dismiss(
                        $0,
                        origin: .code
                    )
                )
            }
            completion?()
        }
    }
    
}

extension DismissHandler: UIAdaptivePresentationControllerDelegate {
    
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        manager.store.dispatch(
            NavigationCompletionAction.dismiss(
                presentationController
                    .presentedViewController
                    .responsibleViewController,
                origin: .user
            )
        )
    }
    
}

extension CanDismissProgrammatically where Self: UIViewController & HasDismissHandler {
    
    public func dismiss(
        animated flag: Bool,
        completion: (() -> Void)? = nil,
        programmatically: Void
    ) {
        dismissHandler.handle(
            {
                dismiss(
                    animated: flag,
                    completion: $0
                )
            },
            completion: completion
        )
    }
    
}

private extension UIViewController {
    
    var responsibleViewController: UIViewController {
        return tabBarController?.navigationController
            ?? tabBarController
            ?? navigationController
            ?? self
    }
    
    func presentedViewControllers(
        consideringPreviousViewControllers viewControllers: [UIViewController]? = nil
    ) -> [UIViewController]? {
        guard let presentedViewController = presentedViewController else { return viewControllers }
        return presentedViewController.presentedViewControllers(
            consideringPreviousViewControllers: [
                viewControllers ?? [],
                [presentedViewController]
            ].reduce([], +)
        )
    }
    
}
