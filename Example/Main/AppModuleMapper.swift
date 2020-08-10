//
//  AppModuleMapper.swift
//
//  Created by Luciano Polit on 8/9/20.
//

import Foundation
import Caesura

class AppModuleMapper {
    
    static let handleAction: ModuleStarterSingleReturn = {
        switch $0 {
        case NavigationCompletionAction.start:
            return Module.Tab.self
        case Module.Tab.ActionType.next:
            return Module.List.self
        default: return nil
        }
    }
    
}
