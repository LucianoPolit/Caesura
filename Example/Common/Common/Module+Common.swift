//
//  Module+Common.swift
//  Common
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

public protocol Module: Caesura.Module {
    static func apiActionDispatcher(
        with api: API
    ) -> APIActionDispatcher<ActionType>
}

extension Module {
    
    public static func apiActionDispatcher(
        with api: Caesura.API
    ) -> APIActionDispatcher<ActionType> {
        guard let api = api as? API else { return APIActionDispatcher() }
        return apiActionDispatcher(with: api)
    }
    
    public static func apiActionDispatcher(
        with api: API
    ) -> APIActionDispatcher<ActionType> {
        return APIActionDispatcher()
    }
    
}

extension Module {
    
    public static var stopAction: ActionType {
        fatalError("Module.stopAction should be implemented")
    }
    
}
