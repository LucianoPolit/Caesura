//
//  APIActionDispatcherTests.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

class APIActionDispatcherTests: TestCase {
    
    let dispatcher = APIActionDispatcher<TestAction>()
    
}

extension APIActionDispatcherTests {
    
    func testDefaultResponse() {
        expect(
            self.dispatcher.dispatch(
                .start,
                to: { _ in }
            )
        ).to(
            beFalse()
        )
    }
    
}

extension APIActionDispatcherTests {
    
    func testHandleSuccess() {
        var number = 0
        dispatcher.handle(
            request: { completion in
                completion(
                    .success(1)
                )
            },
            loading: TestAction.loading,
            success: TestAction.success,
            failure: { _ in .failure(.first) }
        ) { action in
            switch number {
            case 0: expect(action) == .loading
            case 1: expect(action) == .success(1)
            default: fail()
            }
            number += 1
        }
        expect(number) == 2
    }
    
    func testHandleFailure() {
        var number = 0
        dispatcher.handle(
            request: { completion in
                completion(
                    .failure(TestError.first)
                )
            },
            loading: TestAction.loading,
            success: TestAction.success,
            failure: { error in
                guard case TestError.first = error else {
                    fail()
                    return .failure(.first)
                }
                return .failure(.first)
            }
        ) { action in
            switch number {
            case 0: expect(action) == .loading
            case 1: expect(action) == .failure(.first)
            default: fail()
            }
            number += 1
        }
        expect(number) == 2
    }
    
    func testHandleSuccessWithSuccessMappingSet() {
        var number = 0
        dispatcher.handle(
            request: { completion in
                completion(
                    .success("1")
                )
            },
            loading: TestAction.loading,
            success: TestAction.success,
            failure: { _ in .failure(.first) },
            mapSuccess: { value in
                expect(value) == "1"
                return 1
            }
        ) { action in
            switch number {
            case 0: expect(action) == .loading
            case 1: expect(action) == .success(1)
            default: fail()
            }
            number += 1
        }
        expect(number) == 2
    }
    
    func testHandleFailureWithSuccessMappingSet() {
        var number = 0
        dispatcher.handle(
            request: { completion in
                completion(
                    .failure(TestError.first)
                )
            },
            loading: TestAction.loading,
            success: TestAction.success,
            failure: { error in
                guard case TestError.first = error else {
                    fail()
                    return .failure(.first)
                }
                return .failure(.first)
            },
            mapSuccess: { $0 }
        ) { action in
            switch number {
            case 0: expect(action) == .loading
            case 1: expect(action) == .failure(.first)
            default: fail()
            }
            number += 1
        }
        expect(number) == 2
    }
    
    func testHandleFailureWithMappingSet() {
        var number = 0
        dispatcher.handle(
            request: { completion in
                completion(
                    .failure(TestError.first)
                )
            },
            loading: TestAction.loading,
            success: TestAction.success,
            failure: { error in
                guard case TestError.second = error else {
                    fail()
                    return .failure(.second)
                }
                return .failure(.second)
            },
            mapSuccess: { $0 },
            mapFailure: { error in
                guard case TestError.first = error else {
                    fail()
                    return TestError.first
                }
                return TestError.second
            }
        ) { action in
            switch number {
            case 0: expect(action) == .loading
            case 1: expect(action) == .failure(.second)
            default: fail()
            }
            number += 1
        }
        expect(number) == 2
    }
    
}
