//
//  ViewControllerConnection.swift
//  List
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation

extension ViewController {
    
    struct Props {
        let list: [String]
    }
    
    static func mapStateToProps(
        _ state: State
    ) -> Props {
        return Props(
            list: state.sort == .ascending ?
                state.listState.values : state.listState.values.reversed()
        )
    }
    
}

extension ViewController {
    
    typealias DispatchFunction = (Action) -> Void
    
    struct Events {
        let didLoad: () -> Void
        let didTapLeftBarButton: () -> Void
        let didTapRightBarButton: () -> Void
        let didSelectOption: (String) -> Void
    }
    
    static func mapDispatchToEvents(
        _ dispatch: @escaping DispatchFunction
    ) -> Events {
        return Events(
            didLoad: {
                dispatch(.fetch)
            },
            didTapLeftBarButton: {
                dispatch(.toggleSort)
            },
            didTapRightBarButton: {
                dispatch(.add("Something cool!"))
            },
            didSelectOption: {
                dispatch(.next($0))
            }
        )
    }
    
}
