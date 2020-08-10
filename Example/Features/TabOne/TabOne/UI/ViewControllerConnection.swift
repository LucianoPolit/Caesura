//
//  ViewControllerConnection.swift
//  TabOne
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import TabTwo

extension ViewController {
    
    struct Props {
        let rightBarButtonTitle: String
    }
    
    static func mapStateToProps(
        _ state: DoubleStateContainer<State, TabTwo.State>
    ) -> Props {
        return Props(
            rightBarButtonTitle: state.second.isStarted ? "Remove" : "Add"
        )
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
                dispatch(
                    Module.TabTwo.state().isStarted ? .remove : .add
                )
            }
        )
    }
    
}
