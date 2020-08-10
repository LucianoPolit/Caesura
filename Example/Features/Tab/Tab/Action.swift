//
//  Action.swift
//  Tab
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

public enum Action: String, Caesura.Action, StandardActionConvertible {
    case start
    case next
}
