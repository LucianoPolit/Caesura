//
//  ActionTests.swift
//  ListTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import CommonTests
@testable import List

class ActionTests: XCTestCase { }

// MARK: - Standard Action

extension ActionTests: StandardActionTestCase {

    typealias ActionType = Action

    func testStandardActionConvertibility() {
        #if arch(x86_64)
        expect(
            try self.testStandardActionConvertibility(
                [
                    .start,
                    .fetch,
                    .loading,
                    .error(.unknown),
                    .set(["..."]),
                    .add("..."),
                    .toggleSort,
                    .next("...")
                ]
            )
        ).toNot(
            throwAssertion()
        )
        #endif
    }

}
