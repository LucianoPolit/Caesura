//
//  LoggerMiddleware.swift
//  Middlewares
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import AwesomeUtilities

public class LoggerMiddleware: Caesura.LoggerMiddleware {
    
    override public func log(
        _ action: Action
    ) {
        if action is TimelineCompletionAction { return }
        Logger.shared.logDebug("\(action)")
    }
    
}
