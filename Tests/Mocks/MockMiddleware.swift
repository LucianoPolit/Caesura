//
//  MockMiddleware.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import ReSwift

class MockMiddleware: Caesura.Middleware {
    
    let actionHandler: (Action) -> Void
    
    init(
        actionHandler: @escaping (Action) -> Void
    ) {
        self.actionHandler = actionHandler
    }
    
    func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.actionHandler(action)
                next(action)
            }
        }
    }
    
}

extension MockMiddleware {
    
    static func asFunction(
        actionHandler: @escaping (Action) -> Void
    ) -> ReSwift.Middleware<State> {
        return { dispatch, state in
            return { next in
                return { action in
                    actionHandler(action)
                    next(action)
                }
            }
        }
    }
    
}
