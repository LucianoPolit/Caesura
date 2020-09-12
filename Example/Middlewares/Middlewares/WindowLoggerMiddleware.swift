//
//  WindowLoggerMiddleware.swift
//  Middlewares
//
//  Created by Luciano Polit on 9/12/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import AwesomeUtilities

public class WindowLoggerMiddleware: Caesura.LoggerMiddleware {
    
    public override func log(
        _ action: Action
    ) {
        guard let route = UIApplication.shared.keyWindow?.route,
            action is NavigationCompletionAction
            else { return }
        Logger.shared.logDebug(route)
    }
    
}

private extension UIWindow {
    
    var route: String? {
        return rootViewController?.route()
    }
    
}

private extension UIViewController {
    
    func route(
        consideringBaseRoute route: String = ""
    ) -> String {
        var route = route + "/\(String(reflecting: type(of: self)))"
        if let tabBarController = self as? UITabBarController,
            let viewController = tabBarController.viewControllers?[safe: tabBarController.selectedIndex] {
            route = viewController.route(
                consideringBaseRoute: route
            )
        } else if let navigationController = self as? UINavigationController {
            navigationController.viewControllers.first?.do {
                route = $0.route(
                    consideringBaseRoute: route + "/*"
                )
            }
            navigationController.viewControllers
                .removing(at: 0)
                .forEach {
                    route = $0.route(
                        consideringBaseRoute: route + "/>"
                    )
                }
        } else if let presentedViewController = presentedViewController {
            if let navigationController = navigationController {
                if navigationController.viewControllers.last == self {
                    route = presentedViewController.route(
                        consideringBaseRoute: route + "/^"
                    )
                }
            } else {
                route = presentedViewController.route(
                    consideringBaseRoute: route + "/^"
                )
            }
        }
        return route
    }
    
}
