//
//  Middleware+Utils.swift
//  Middlewares
//
//  Created by Luciano Polit on 8/17/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

extension Array where Element == Middleware {
    
    public static func general(
        store: StandardActionStore = .default
    ) -> [Middleware] {
        return [
            CrashDetectorMiddleware(),
            RecorderMiddleware(
                store: store
            ),
            ReporterMiddleware(
                store: store
            ) {
                print($0)
            },
            LoggerMiddleware(),
            KickOffMiddleware()
        ]
    }
    
}
