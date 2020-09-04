//
//  MiddlewareWrapperTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
@testable import Caesura

class MiddlewareWrapperTests: TestCase { }

extension MiddlewareWrapperTests {
    
    func testFunctionality() {
        waitUntil { done in
            var number = 0
            let wrapper = MiddlewareWrapper { dispatch, state in
                expect(number) == 0
                expect(state()).toNot(beNil())
                dispatch(TestAction.fetch)
                return { next in
                    return { action in
                        expect(number) == 1
                        next(action)
                        expect(number) == 2
                        done()
                    }
                }
            }
            wrapper.testIntercept(
                withAction: TestAction.start,
                dispatch: {
                    guard case TestAction.fetch = $0 else { return }
                    number += 1
                },
                next: {
                    guard case TestAction.start = $0 else { return }
                    number += 1
                }
            )
        }
    }
    
}
