//
//  UIViewController+Utils.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    @discardableResult
    func asRootOfKeyWindow() -> Self {
        UIWindow().do {
            $0.rootViewController = self
            $0.makeKeyAndVisible()
        }
        return self
    }
    
}
