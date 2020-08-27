//
//  UIKit+Utils.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    
    public func sendAction() {
        guard let action = action,
            let target = target
            else { return }
        UIApplication.shared.sendAction(
            action,
            to: target,
            from: nil,
            for: nil
        )
    }
    
}
