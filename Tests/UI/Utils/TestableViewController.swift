//
//  TestableViewController.swift
//  Tests
//
//  Created by Luciano Polit on 8/28/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

class TestableViewController: ViewController {
    
    private let actionHandler: (Action) -> Void
    
    override var manager: Manager {
        return MockManager(
            actionHandler: actionHandler
        ).start()
    }
    
    init(
        actionHandler: @escaping (Action) -> Void
    ) {
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TestableNavigationController: NavigationController {
    
    private let actionHandler: (Action) -> Void
    
    override var manager: Manager {
        return MockManager(
            actionHandler: actionHandler
        ).start()
    }
    
    init(
        actionHandler: @escaping (Action) -> Void
    ) {
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TestableTabBarController: TabBarController {
    
    private let actionHandler: (Action) -> Void
    
    override var manager: Manager {
        return MockManager(
            actionHandler: actionHandler
        ).start()
    }
    
    init(
        actionHandler: @escaping (Action) -> Void
    ) {
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
