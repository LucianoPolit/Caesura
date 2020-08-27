//
//  ReducerTests.swift
//  ListTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Common
import XCTest
import Nimble
@testable import List

class ReducerTests: XCTestCase {
    
    let reducer = Module.reducer
    
}

// MARK: - Actions

extension ReducerTests {
    
    func testLoading() {
        let state = reducer(
            .loading,
            .init()
        )
        expect(
            state.listState
        ).to(
            equal(.loading)
        )
    }
    
    func testSet() {
        let values = ["1", "2", "3"]
        let state = reducer(
            .set(values),
            .init()
        )
        expect(
            state.listState.values
        ).to(
            equal(values)
        )
    }
    
    func testError() {
        let state = reducer(
            .error(.unknown),
            .init()
        )
        expect(
            state.listState
        ).to(
            equal(.error(.unknown))
        )
    }
    
    func testAdd() {
        let result = ["1", "2"]
        let oldState = State(
            listState: .results([result[0]]),
            sort: .ascending
        )
        let state = reducer(
            .add(result[1]),
            oldState
        )
        expect(
            state.listState.values
        ).to(
            equal(result)
        )
    }
    
    func testToggleSortFromAscending() {
        let oldState = State(
            listState: .empty,
            sort: .ascending
        )
        let state = reducer(
            .toggleSort,
            oldState
        )
        expect(
            state.sort
        ).to(
            equal(.descending)
        )
    }
    
    func testToggleSortFromDescending() {
        let oldState = State(
            listState: .empty,
            sort: .descending
        )
        let state = reducer(
            .toggleSort,
            oldState
        )
        expect(
            state.sort
        ).to(
            equal(.ascending)
        )
    }
    
}
