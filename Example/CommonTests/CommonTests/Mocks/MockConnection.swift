//
//  MockConnection.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
@testable import ReRxSwift

public class MockConnection<Props, Events>: Connection<State, Props, Events> {
    
    public convenience init(
        props: Props,
        events: Events,
        manager: Manager = .main
    ) {
        self.init(
            store: manager.store,
            mapStateToProps: { _ in props },
            mapDispatchToActions: { _ in events }
        )
    }
    
    public var connectCalled = false
    public override func connect() {
        connectCalled = true
    }
    
    public var disconnectCalled = false
    public override func disconnect() {
        disconnectCalled = true
    }
    
}
