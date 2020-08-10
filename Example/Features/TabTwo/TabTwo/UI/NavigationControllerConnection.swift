//
//  NavigationControllerConnection.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit

extension NavigationController {
    
    struct Props { }
    
    static func mapStateToProps(
        _ state: State
    ) -> Props {
        return Props()
    }
    
}

extension NavigationController {
    
    typealias DispatchFunction = (Action) -> Void
    
    struct Events {
        let didMoveToParent: (UIViewController?) -> Void
    }
    
    static func mapDispatchToEvents(
        _ dispatch: @escaping DispatchFunction
    ) -> Events {
        return Events(
            didMoveToParent: {
                dispatch(
                    $0 == nil ? .didStop : .didStart
                )
            }
        )
    }
    
}
