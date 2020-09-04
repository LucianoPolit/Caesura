//
//  MockViewController.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit

class MockViewController: UIViewController {
    
    var presentCalled = false
    var presentParameters: (UIViewController, Bool, (() -> Void)?)?
    var presentShouldCallSuper = true
    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentCalled = true
        presentParameters = (
            viewControllerToPresent,
            flag,
            completion
        )
        guard presentShouldCallSuper else { return }
        super.present(
            viewControllerToPresent,
            animated: flag,
            completion: completion
        )
    }
    
    var dismissCalled = false
    var dismissParameters: (Bool, (() -> Void)?)?
    override func dismiss(
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        dismissCalled = true
        dismissParameters = (
            flag,
            completion
        )
    }
    
}
