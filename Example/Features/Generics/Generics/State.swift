//
//  State.swift
//  Generics
//
//  Created by Luciano Polit on 8/18/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import Then

public struct State: StateType, Then, Equatable {
    
    public var value = true.description
    
}
