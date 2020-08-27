//
//  ViewControllerConnectionTests.swift
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

class ViewControllerConnectionTests: XCTestCase { }

// MARK: - State To Props

extension ViewControllerConnectionTests {
    
    func testListEmpty() {
        expect(
            ViewController.mapStateToProps(
                State(
                    listState: .empty,
                    sort: .ascending
                )
            ).list
        ).to(
            beEmpty()
        )
    }
    
    func testListResultsAscending() {
        let results = ["1", "2", "3"]
        expect(
            ViewController.mapStateToProps(
                State(
                    listState: .results(results),
                    sort: .ascending
                )
            ).list
        ).to(
            equal(results)
        )
    }
    
    func testListResultsDescending() {
        let results = ["1", "2", "3"]
        expect(
            ViewController.mapStateToProps(
                State(
                    listState: .results(results),
                    sort: .descending
                )
            ).list
        ).to(
            equal(
                results.reversed()
            )
        )
    }
    
    func testListError() {
        expect(
            ViewController.mapStateToProps(
                State(
                    listState: .error(.unknown),
                    sort: .ascending
                )
            ).list
        ).to(
            beEmpty()
        )
    }
    
}

// MARK: - Dispatch To Events

extension ViewControllerConnectionTests {
    
    func testDidLoad() {
        waitUntil { done in
            ViewController
                .mapDispatchToEvents { action in
                    expect(
                        action
                    ).to(
                        equal(.fetch)
                    )
                    done()
                }
                .didLoad()
        }
    }
    
    func testDidTapLeftBarButton() {
        waitUntil { done in
            ViewController
                .mapDispatchToEvents { action in
                    expect(
                        action
                    ).to(
                        equal(
                            .toggleSort
                        )
                    )
                    done()
                }
                .didTapLeftBarButton()
        }
    }
    
    func testDidTapRightBarButton() {
        waitUntil { done in
            ViewController
                .mapDispatchToEvents { action in
                    expect(
                        action
                    ).to(
                        equal(
                            .add("Something cool!")
                        )
                    )
                    done()
                }
                .didTapRightBarButton()
        }
    }
    
    func testDidSelectOption() {
        waitUntil { done in
            let option = "..."
            ViewController
                .mapDispatchToEvents { action in
                    expect(
                        action
                    ).to(
                        equal(
                            .next(option)
                        )
                    )
                    done()
                }
                .didSelectOption(option)
        }
    }
    
}
