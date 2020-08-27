//
//  ViewControllerTestCase.swift
//  CommonTests
//
//  Created by Luciano Polit on 8/27/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import UIKit
import Caesura
import RxCocoa

public protocol TestableProps {
    static var `default`: Self { get }
}

public protocol MockEvents: class {
    associatedtype EventsType
    var value: EventsType { get }
}

public protocol ViewControllerTestCase: class {
    associatedtype PropsType
    associatedtype EventsType
    associatedtype ViewControllerType: UIViewController & Connectable
    var connection: MockConnection<PropsType, EventsType> { get }
    var viewController: ViewControllerType { get }
}

extension ViewControllerTestCase {
    
    public var props: BehaviorRelay<PropsType> {
        return connection.props
    }
    
}
