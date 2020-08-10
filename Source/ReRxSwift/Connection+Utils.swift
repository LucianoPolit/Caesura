//
//  Connection+Utils.swift
//
//  Copyright (c) 2020 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import ReSwift
import ReRxSwift
#if !COCOAPODS
import Caesura
#endif

public typealias Connection = ReRxSwift.Connection
public typealias Connectable = ReRxSwift.Connectable

extension Connection {
    
    public typealias Transform<State, SelectedState> = (State) -> SelectedState
    public typealias MapStateToProps<State, Props> = (State) -> Props
    public typealias MapDispatchToActions = (@escaping DispatchFunction) -> Actions
    
    public convenience init<S: StateType>(
        store: ReSwift.Store<State>,
        transform: @escaping Transform<State, S>,
        mapStateToProps: @escaping MapStateToProps<S, Props>,
        mapDispatchToActions: @escaping MapDispatchToActions
    ) {
        self.init(
            store: store,
            mapStateToProps: {
                mapStateToProps(
                    transform($0)
                )
            },
            mapDispatchToActions: mapDispatchToActions
        )
    }
    
}

extension Connection where State == Caesura.State {
    
    public static func toManager<S: StateType>(
        _ manager: Manager = Manager.main,
        transform: @escaping Transform<State, S>,
        mapStateToProps: @escaping MapStateToProps<S, Props>,
        mapDispatchToEvents: @escaping MapDispatchToActions
    ) -> Connection<State, Props, Actions> {
        return Connection(
            store: manager.store,
            transform: transform,
            mapStateToProps: mapStateToProps,
            mapDispatchToActions: mapDispatchToEvents
        )
    }
    
}

extension Connectable where AppStateType == State {
    
    public typealias EventsType = ActionsType
    
    public var events: EventsType {
        return actions
    }
    
}
