//
//  AppDelegate.swift
//
//  Created by Luciano Polit on 8/7/20.
//

import UIKit
import Caesura
import API
import Middlewares
import List
import Tab
import Generics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let caesura = Manager.main
        .register(
            api: Manager()
        )
        .register(
            middlewares: .debug(),
            priority: .high
        )
        .register(
            middlewares: .general()
        )
        .register(actionRegistrable: StandardActionStore.default)
        .register(reducer: TimelineReducer.handleAction)
        .register(moduleMapper: AppModuleMapper.handleAction)
        .register(moduleMapper: Module.Tab.moduleMapper)
        .register(module: Module.List.self)
        .register(module: Module.Tab.self)
        .register(module: Module.TabOne.self)
        .register(module: Module.TabTwo.self)
        .register(module: Module.Generics.self)
        .start()
    
}
