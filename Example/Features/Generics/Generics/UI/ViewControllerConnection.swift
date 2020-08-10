//
//  ViewControllerConnection.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

extension ViewController {
    
    struct Props {
        let title: String
    }
    
    static func mapStateToProps(
        _ state: State
    ) -> Props {
        return Props(
            title: state.value
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
                    { () -> ActionProtocol in
                        switch Module.state().value {
                        case "123": return ChangeValueAction(value: "string")
                        case "string": return ChangeValueAction(value: true)
                        default: return ChangeValueAction(value: 123)
                        }
                    }().wrapped()
                )
            }
        )
    }
    
}
