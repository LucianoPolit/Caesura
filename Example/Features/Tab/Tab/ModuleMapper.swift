//
//  ModuleMapper.swift
//  Tab
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import TabOne
import TabTwo

extension TabModule {
    
    public static let moduleMapper: ModuleMapper = {
        switch $0 {
        case Action.start:
            return [
                .start(Module.Tab.self),
                .start(Module.TabOne.self)
            ]
        case Caesura.Module.TabOne.ActionType.add:
            return [
                .start(Module.TabTwo.self)
            ]
        case Caesura.Module.TabOne.ActionType.remove:
            return [
                .stop(Module.TabTwo.self)
            ]
        case Caesura.Module.TabTwo.ActionType.next:
            return [
                .replace(with: Action.next)
            ]
        default: return nil
        }
    }
    
}
