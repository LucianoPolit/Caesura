//
//  Middleware+Utils.swift
//  Tests
//
//  Created by Luciano Polit on 9/3/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

extension Middleware {
    
    func testIntercept(
        withAction action: Action,
        dispatch: @escaping ((Action) -> Void) = { _ in fail() },
        next: @escaping ((Action) -> Void) = { _ in fail() }
    ) {
        testIntercept(
            withActions: [action],
            dispatch: dispatch,
            next: next
        )
    }
    
    func testIntercept(
        withActions actions: [Action],
        dispatch: @escaping ((Action) -> Void) = { _ in fail() },
        next: @escaping ((Action) -> Void) = { _ in fail() }
    ) {
        actions.forEach(
            intercept(
                dispatch: dispatch,
                state: { State() }
            )(next)
        )
    }
    
}
