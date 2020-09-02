//
//  TestAction.swift
//  Tests
//
//  Created by Luciano Polit on 9/2/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

enum TestAction: Action, Equatable {
    case start
    case fetch
    case loading
    case success(Int)
    case failure(TestError)
    case stop
}
