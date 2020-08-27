//
//  ViewControllerTests.swift
//  ListTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import Nimble
import AwesomeUtilitiesTests
import CommonTests
@testable import List

class ViewControllerTests: XCTestCase, ViewControllerTestCase {
    
    let events = MockViewControllerEvents()
    lazy var connection = MockConnection(
        props: ViewController.Props.default,
        events: events.value
    )
    lazy var viewController: ViewController = {
        let viewController = ViewController()
        viewController.connection = connection
        return viewController
    }()
    
}

// MARK: - Connection

extension ViewControllerTests {
    
    func testConnect() {
        expect(
            self.connection.connectCalled
        ).to(
            beFalse()
        )
        viewController.viewWillAppear(true)
        expect(
            self.connection.connectCalled
        ).to(
            beTrue()
        )
    }
    
    func testDisconnect() {
        expect(
            self.connection.disconnectCalled
        ).to(
            beFalse()
        )
        viewController.viewWillDisappear(true)
        expect(
            self.connection.disconnectCalled
        ).to(
            beTrue()
        )
    }
    
}

// MARK: - UI

extension ViewControllerTests {
    
    func testTableViewDataSource() {
        let dataSource = [
            "First",
            "Second",
            "Third"
        ]
        connection = MockConnection(
            props: .init(
                list: dataSource
            ),
            events: events.value
        )
        viewController.loadViewIfNeeded()
        expect(
            (
                self.viewController.view
                .findFirst(
                    ofType: UITableView.self
                )?
                .cellForRow(
                    at: IndexPath(
                        item: 0,
                        section: 0
                    )
                ) as? TableViewCell
            )?
            .titleLabel
            .text
        ).to(
            equal("First")
        )
    }
    
}

// MARK: - Events

extension ViewControllerTests {
    
    func testDidLoad() {
        expect(
            self.events.didLoadCalled
        ).to(
            beFalse()
        )
        viewController.loadViewIfNeeded()
        expect(
            self.events.didLoadCalled
        ).to(
            beTrue()
        )
    }
    
    func testDidTapLeftBarButton() {
        expect(
            self.events.didTapLeftBarButtonCalled
        ).to(
            beFalse()
        )
        viewController.loadViewIfNeeded()
        viewController.navigationItem.leftBarButtonItem?.sendAction()
        expect(
            self.events.didTapLeftBarButtonCalled
        ).to(
            beTrue()
        )
    }
    
    func testDidTapRightBarButton() {
        expect(
            self.events.didTapRightBarButtonCalled
        ).to(
            beFalse()
        )
        viewController.loadViewIfNeeded()
        viewController.navigationItem.rightBarButtonItem?.sendAction()
        expect(
            self.events.didTapRightBarButtonCalled
        ).to(
            beTrue()
        )
    }
    
    func testDidSelectOption() {
        expect(
            self.events.didSelectOptionCalled
        ).to(
            beFalse()
        )
        connection = MockConnection(
            props: .init(
                list: [
                    "First",
                    "Second",
                    "Third"
                ]
            ),
            events: events.value
        )
        viewController.loadViewIfNeeded()
        viewController.view
            .findFirst(
                ofType: UITableView.self
            )?
            .delegate?
            .tableView?(
                .init(),
                didSelectRowAt: IndexPath(
                    item: 0,
                    section: 0
                )
            )
        expect(
            self.events.didSelectOptionCalled
        ).to(
            beTrue()
        )
    }
    
}

// MARK: - Utils

class MockViewControllerEvents: MockEvents {
    
    lazy var value = ViewController.Events(
        didLoad: {
            self.didLoadCalled = true
        },
        didTapLeftBarButton: {
            self.didTapLeftBarButtonCalled = true
        },
        didTapRightBarButton: {
            self.didTapRightBarButtonCalled = true
        },
        didSelectOption: {
            self.didSelectOptionCalled = true
            self.didSelectOptionParameters = $0
        }
    )
    
    var didLoadCalled = false
    var didTapLeftBarButtonCalled = false
    var didTapRightBarButtonCalled = false
    var didSelectOptionCalled = false
    var didSelectOptionParameters: String?
    
}

extension ViewController.Props: TestableProps {
    
    public static var `default` = ViewController.Props(
        list: []
    )
    
}
