//
//  ViewControllerConnection.swift
//  TabTwo
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation

extension ViewController {
    
    struct Props { }
    
    static func mapStateToProps(
        _ state: State
    ) -> Props {
        return Props()
    }
    
}

extension ViewController {
    
    typealias DispatchFunction = (Action) -> Void
    
    struct Events {
        let didTapRightBarButton: () -> Void
    }
    
    static func mapDispatchToEvents(
        _ dispatch: @escaping DispatchFunction
    ) -> Events {
        return Events(
            didTapRightBarButton: {
                dispatch(.next)
            }
        )
    }
    
}
