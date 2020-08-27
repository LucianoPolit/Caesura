//
//  APIActionDispatcherTests.swift
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

class APIActionDispatcherTests: XCTestCase {
    
    let client = MockAPI().mockExample
    lazy var dispatcher = APIActionDispatcher(
        exampleClient: client
    )
    
}

// MARK: - Actions

extension APIActionDispatcherTests {
    
    func testFetchSuccess() {
        client.readAllEndpoint.success = true
        waitUntil { done in
            var count = 0
            let result = self.dispatcher.dispatch(.fetch) { action in
                switch count {
                case 0:
                    guard case .loading = action else { return fail() }
                    count += 1
                case 1:
                    guard case .set = action else { return fail() }
                    done()
                default:
                    fail()
                }
            }
            expect(
                result
            ).to(
                beTrue()
            )
        }
    }
    
    func testFetchFailure() {
        client.readAllEndpoint.success = false
        waitUntil { done in
            var count = 0
            let result = self.dispatcher.dispatch(.fetch) { action in
                switch count {
                case 0:
                    guard case .loading = action else { return fail() }
                    count += 1
                case 1:
                    guard case .error = action else { return fail() }
                    done()
                default:
                    fail()
                }
            }
            expect(
                result
            ).to(
                beTrue()
            )
        }
    }
    
}
