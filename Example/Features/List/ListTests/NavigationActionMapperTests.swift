//
//  NavigationActionMapperTests.swift
//  ListTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import Nimble
@testable import List

class NavigationActionMapperTests: XCTestCase {
    
    let mapper = NavigationActionMapper()
    
}

// MARK: - Actions

extension NavigationActionMapperTests {
    
    func testStart() {
        guard let action = mapper.map(.start),
            case .present(let viewController, _) = action,
            let navigationController = viewController as? UINavigationController,
            navigationController.viewControllers.first is ViewController
            else { return fail() }
    }
    
    func testNext() {
        let title = "Title"
        guard let action = mapper.map(.next(title)),
            case .push(let viewController, _) = action
            else { return fail() }
        expect(
            viewController.title
        ).to(
            equal(title)
        )
    }
    
}
