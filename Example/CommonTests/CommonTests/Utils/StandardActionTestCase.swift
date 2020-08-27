//
//  StandardActionTestCase.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

public struct StandardActionTestCaseError: Error { }

public protocol StandardActionTestCase {
    associatedtype ActionType: StandardActionConvertible
}

extension StandardActionTestCase where ActionType: Equatable {

    public func testStandardActionConvertibility(
        _ actions: [ActionType]
    ) throws {
        try actions.forEach {
            guard let standardAction = $0.toStandard(),
                let action = try? ActionType.init(action: standardAction),
                action == $0
                else { throw StandardActionTestCaseError() }
        }
    }

}
