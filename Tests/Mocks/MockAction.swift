//
//  MockAction.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

enum MockAction: Action, Equatable {
    case start
    case fetch
    case stop
}
