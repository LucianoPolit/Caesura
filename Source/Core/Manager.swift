//
//  Manager.swift
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

open class Manager {
    
    public static let main = Manager()
    
    private var api: API?
    private var moduleMappers: [ModuleMapper] = []
    
    private var actionRegistrables: [ActionRegistrable] = []
    private var actionsRegistered: [Action.Type] = []
    private var stateRegistrables: [StateRegistrable] = []
    private var statesRegistered: [StateType.Type] = []
    
    private var navigationActionMappers: [ActionMapperProtocol] = []
    private var apiActionDispatchers: [(API) -> ActionDispatcherProtocol] = []
    
    private var reducers: [Reducer<Action, State>] = []
    private var middlewares: [MiddlewarePriority: [Middleware]] = [
        .high: [],
        .medium: [],
        .low: []
    ]
    
    public private(set) lazy var store = Store(
        reducer: { [reducers] action, state in
            var state = state ?? State()
            reducers.forEach {
                state = $0(action, state)
            }
            return state
        },
        middlewares: {
            middlewares[.low]?.prepend(
                contentsOf: [
                    ModuleMapperMiddleware(
                        mappers: moduleMappers
                    ),
                    NavigationActionMapperMiddleware(
                        mappers: navigationActionMappers
                    ),
                    NavigationMiddleware(),
                    APIActionDispatcherMiddleware(
                        dispatchers: apiActionDispatchers.compactMap {
                            guard let api = api else { return nil }
                            return $0(api)
                        }
                    )
                ]
            )
            return [
                middlewares[.high]!,
                middlewares[.medium]!,
                middlewares[.low]!
            ].reduce([], +)
        }()
    )
    
    public init() { }
    
    open func start() -> Manager {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationNotification),
            name: nil,
            object: nil
        )
        
        store.dispatch(
            ManagerStartCompletion()
        )
        
        api = nil
        moduleMappers.removeAll()
        actionRegistrables.removeAll()
        actionsRegistered.removeAll()
        stateRegistrables.removeAll()
        statesRegistered.removeAll()
        navigationActionMappers.removeAll()
        apiActionDispatchers.removeAll()
        reducers.removeAll()
        middlewares.removeAll()
        
        return self
    }
    
    open func register<M: Module>(
        module: M.Type
    ) -> Manager {
        register(
            actionType: M.ActionType.self
        )
        register(
            stateType: M.StateType.self
        )
        register(
            reducer: M.reducer,
            initialState: M.initialState,
            storeKey: M.storeKey
        )
        register(
            navigationActionMapper: M.navigationActionMapper()
        )
        register(
            apiActionDispatcher: M.apiActionDispatcher
        )
        return self
    }
    
}

extension Manager {
    
    public func register(
        api: API
    ) -> Manager {
        self.api = api
        return self
    }
    
}

extension Manager {
    
    public func register(
        moduleMapper: @escaping ModuleMapper
    ) -> Manager {
        moduleMappers.append(moduleMapper)
        return self
    }
    
    public func register(
        moduleMapper: @escaping ModuleMapperSingleReturn
    ) -> Manager {
        register(
            moduleMapper: {
                guard let response = moduleMapper($0) else { return nil }
                return [response]
            } as ModuleMapper
        )
    }
    
    public func register(
        moduleMapper: @escaping ModuleStarter
    ) -> Manager {
        return register(
            moduleMapper: {
                guard let moduleTypes = moduleMapper($0) else { return nil }
                return moduleTypes.map { .start($0) }
            } as ModuleMapper
        )
    }

    public func register(
        moduleMapper: @escaping ModuleStarterSingleReturn
    ) -> Manager {
        return register(
            moduleMapper: {
                guard let moduleType = moduleMapper($0) else { return nil }
                return [moduleType]
            } as ModuleStarter
        )
    }
    
}

extension Manager {
    
    public func register(
        actionRegistrable: ActionRegistrable
    ) -> Manager {
        actionRegistrable.register(actionType: NavigationAction.self)
        actionRegistrables.append(actionRegistrable)
        return self
    }
    
    public func register(
        stateRegistrable: StateRegistrable
    ) -> Manager {
        stateRegistrables.append(stateRegistrable)
        return self
    }
    
}

extension Manager {
    
    public func register<A: Action>(
        reducer: @escaping Reducer<A, State.Store>
    ) -> Manager {
        reducers.append {
            guard let action = $0 as? A else { return $1 }
            return $1.with { state in
                reducer(action, state.store).forEach {
                    state.set($1, forKey: $0)
                }
            }
        }
        return self
    }
    
}

extension Manager {
    
    public func register(
        middleware: Middleware,
        priority: MiddlewarePriority = .medium
    ) -> Manager {
        middlewares[priority]?.append(middleware)
        return self
    }
    
    public func register(
        middlewares: [Middleware],
        priority: MiddlewarePriority = .medium
    ) -> Manager {
        middlewares.forEach {
            _ = register(
                middleware: $0,
                priority: priority
            )
        }
        return self
    }
    
    public func register(
        middleware: @escaping ReSwift.Middleware<State>,
        priority: MiddlewarePriority = .medium
    ) -> Manager {
        return register(
            middleware: MiddlewareWrapper(middleware),
            priority: priority
        )
    }
    
    public func register(
        middlewares: [ReSwift.Middleware<State>],
        priority: MiddlewarePriority = .medium
    ) -> Manager {
        return register(
            middlewares: middlewares.map(MiddlewareWrapper.init),
            priority: priority
        )
    }
    
}

private extension Manager {
    
    func register(
        actionType type: Action.Type
    ) {
        guard !actionsRegistered.contains(where: { $0 == type }) else { return }
        actionRegistrables.forEach {
            $0.register(actionType: type)
        }
        actionsRegistered.append(type)
    }
    
    func register(
        stateType type: StateType.Type
    ) {
        guard !statesRegistered.contains(where: { $0 == type }) else { return }
        stateRegistrables.forEach {
            $0.register(stateType: type)
        }
        statesRegistered.append(type)
    }
    
}

private extension Manager {
    
    func register<A: Action, S: StateType>(
        reducer: @escaping Reducer<A, S>,
        initialState: S,
        storeKey: String
    ) {
        reducers.append {
            guard let action = $0 as? A else { return $1 }
            return $1.with {
                $0.set(
                    reducer(
                        action,
                        $0.value(forKey: storeKey) ?? initialState
                    ),
                    forKey: storeKey
                )
            }
        }
    }
    
}

private extension Manager {
    
    func register<A: Action>(
        navigationActionMapper: NavigationActionMapper<A>
    ) {
        navigationActionMappers.append(navigationActionMapper)
    }
    
    func register<A: Action>(
        apiActionDispatcher: @escaping (API) -> APIActionDispatcher<A>
    ) {
        apiActionDispatchers.append(apiActionDispatcher)
    }
    
}

public struct ManagerStartCompletion: Action, CustomStringConvertible {
    
    public var description: String {
        return "CaesuraStartCompletion()"
    }
    
}
