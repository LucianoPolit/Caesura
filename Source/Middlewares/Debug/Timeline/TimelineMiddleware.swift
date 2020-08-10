//
//  TimelineMiddleware.swift
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
#if !COCOAPODS
import Caesura
#endif

public class TimelineMiddleware: DebugMiddleware {
    
    private var states: [State?] = []
    private var current = 0
    private var ignore = false
    
    public init() { }
    
    public func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.handle(
                    action: action,
                    state: state,
                    next: next,
                    dispatch: dispatch
                )
            }
        }
    }
    
}

private extension TimelineMiddleware {
    
    func handle(
        action: Action,
        state: () -> State?,
        next: DispatchFunction,
        dispatch: DispatchFunction
    ) {
        guard !ignore else {
            ignore = false
            next(TimelineCompletionAction.ignore)
            next(action)
            return
        }
        
        guard let timelineAction = action as? TimelineAction else {
            let removed = states.count > current
            while states.count > current {
                states.removeLast()
            }
            
            if removed || states.isEmpty {
                states.append(state())
            }
            
            current += 1
            next(action)
            next(TimelineCompletionAction.current(current))
            next(TimelineCompletionAction.total(current))
            states.append(state())
            return
        }
        
        handle(
            action: timelineAction,
            next: next,
            dispatch: dispatch
        )
    }
    
}

private extension TimelineMiddleware {
    
    func handle(
        action: TimelineAction,
        next: DispatchFunction,
        dispatch: DispatchFunction
    ) {
        switch action {
        case .back:
            guard current > 0 else { return }
            defer { next(TimelineCompletionAction.back) }
            current -= 1
            guard let state = states[current] else { break }
            dispatch(
                TimelineAction.setState(state.store)
            )
        case .forward:
            guard current < states.count - 1 else { return }
            defer { next(TimelineCompletionAction.forward) }
            current += 1
            guard let state = states[current] else { break }
            dispatch(
                TimelineAction.setState(state.store)
            )
        case .ignore:
            ignore = true
            return
        case .setState:
            next(action)
            return
        }
        
        next(TimelineCompletionAction.current(current))
    }
    
}
