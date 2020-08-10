//
//  ModuleMapperMiddleware.swift
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

class ModuleMapperMiddleware: Middleware {
    
    let mappers: [ModuleMapper]
    
    init(
        mappers: [ModuleMapper]
    ) {
        self.mappers = mappers
    }
    
    func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.callMappersOrNext(
                    withAction: action,
                    next: next
                )
            }
        }
    }
    
}

private extension ModuleMapperMiddleware {
    
    func callMappersOrNext(
        withAction action: Action,
        skipingAt skipIndex: Int? = nil,
        next: @escaping DispatchFunction
    ) {
        if !mappers
            .enumerated()
            .compactMap({ index, _ in
                guard skipIndex != index else { return nil }
                return callMapper(
                    at: index,
                    withAction: action,
                    next: next
                )
            })
            .contains(true) {
            next(action)
        }
    }
    
}

private extension ModuleMapperMiddleware {
    
    func callMapper(
        at index: Int,
        withAction action: Action,
        next: @escaping DispatchFunction
    ) -> Bool {
        guard let mapper = mappers[safe: index],
            let mappedActions = mapper(action)?.toActions()
            else { return false }
        
        mappedActions.forEach { action in
            callMappersOrNext(
                withAction: action,
                skipingAt: index,
                next: next
            )
        }
        
        return true
    }
    
}

private extension Array where Element == ModuleMapperReturnType {
    
    func toActions() -> [Action] {
        return map {
            switch $0 {
            case .start(let module):
                return module.startAction()
            case .stop(let module):
                return module.stopAction()
            case .replace(let action):
                return action
            }
        }
    }
    
}
