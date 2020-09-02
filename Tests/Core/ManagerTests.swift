//
//  ManagerTests.swift
//  Tests
//
//  Created by Luciano Polit on 8/31/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Nimble
import Caesura

class ManagerTests: TestCase { }

extension ManagerTests {
    
    func testStartDispatchesCompletionAction() {
        waitUntil { done in
            _ = Manager()
                .register(
                    middleware: { dispatch, state in
                        return { next in
                            return { action in
                                guard action is ManagerStartCompletion else { return }
                                done()
                            }
                        }
                    }
                )
                .start()
        }
    }
    
    func testNotificationCenterDispatchesCompletion() {
        waitUntil { done in
            var allCases = ApplicationCompletionAction.allCases
            let manager = Manager()
                .register(
                    middleware: { dispatch, state in
                        return { next in
                            return { action in
                                guard let action = action as? ApplicationCompletionAction,
                                    let index = allCases.firstIndex(of: action)
                                    else { return }
                                allCases.remove(at: index)
                                guard allCases.isEmpty else { return }
                                done()
                            }
                        }
                    }
                )
                .start()
            NotificationCenter.default.post(
                name: UIApplication.didFinishLaunchingNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.didReceiveMemoryWarningNotification,
                object: nil
            )
            NotificationCenter.default.post(
                name: UIApplication.willTerminateNotification,
                object: nil
            )
            expect(manager) === manager
        }
    }
    
    func testRegisteringIsDisabledAfterStarting() {
        var condition = false
        
        MockModule.reducerFactory = {
            MockReducer(
                actionHandler: { _ in
                    condition = true
                }
            ).handleAction
        }
        MockModule.navigationActionMapperFactory = {
            MockNavigationActionMapper { _ in
                condition = true
            }
        }
        MockModule.apiActionDispatcherFactory = {
            MockAPIActionDispatcher(api: $0) { _ in
                condition = true
            }
        }
        
        _ = Manager()
            .start()
            .register(
                api: TestAPI()
            )
            .register(
                middleware: { dispatch, state in
                    return { next in
                        return { action in
                            condition = true
                            next(action)
                        }
                    }
                }
            )
            .register(
                reducer: { (action: TestAction, state) in
                    condition = true
                    return state
                }
            )
            .register(
                moduleMapper: { action in
                    condition = true
                    return nil
                } as ModuleMapper
            )
            .register(
                module: MockModule.self
            )
            .start()
        
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
}

extension ManagerTests {
    
    func testRegisterModuleActionType() {
        waitUntil { done in
            var number = 0
            _ = Manager()
                .register(
                    actionRegistrable: MockActionRegistrable { action in
                        defer { number += 1 }
                        switch number {
                        case 0:
                            guard action == NavigationAction.self else { return fail() }
                        default:
                            guard action == TestAction.self else { return fail() }
                            done()
                        }
                    }
                )
                .register(
                    module: MockModule.self
                )
                .start()
        }
    }
    
    func testRegisterModuleActionTypeDoesNotRegisterItTwice() {
        var condition = false
        var number = 0
        _ = Manager()
            .register(
                actionRegistrable: MockActionRegistrable { action in
                    defer { number += 1 }
                    switch number {
                    case 0:
                        guard action == NavigationAction.self else { return fail() }
                    case 1:
                        guard action == TestAction.self else { return fail() }
                    default:
                        condition = true
                    }
                }
            )
            .register(
                module: MockModule.self
            )
            .register(
                module: MockModule.self
            )
            .start()
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
    func testRegisterModuleStateType() {
        waitUntil { done in
            _ = Manager()
                .register(
                    stateRegistrable: MockStateRegistrable { state in
                        guard state == TestState.self else { return fail() }
                        done()
                    }
                )
                .register(
                    module: MockModule.self
                )
                .start()
        }
    }
    
    func testRegisterModuleStateTypeDoesNotRegisterItTwice() {
        var condition = false
        var number = 0
        _ = Manager()
            .register(
                stateRegistrable: MockStateRegistrable { state in
                    defer { number += 1 }
                    switch number {
                    case 0:
                        guard state == TestState.self else { return fail() }
                    default:
                        condition = true
                    }
                }
            )
            .register(
                module: MockModule.self
            )
            .register(
                module: MockModule.self
            )
            .start()
        expect(condition).toEventuallyNot(beTrue(), timeout: 1)
    }
    
    func testRegisterModuleReducer() {
        waitUntil { done in
            MockModule.reducerFactory = {
                MockReducer(
                    actionHandler: { action in
                        expect(action) == .start
                        done()
                    }
                ).handleAction
            }
            Manager()
                .register(
                    module: MockModule.self
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterNavigationActionMapper() {
        waitUntil { done in
            MockModule.navigationActionMapperFactory = {
                MockNavigationActionMapper { action in
                    expect(action) == .start
                    done()
                }
            }
            Manager()
                .register(
                    module: MockModule.self
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterAPIActionDispatcher() {
        waitUntil { done in
            MockModule.apiActionDispatcherFactory = {
                MockAPIActionDispatcher(api: $0) { action in
                    expect(action) == .fetch
                    done()
                }
            }
            Manager()
                .register(
                    api: TestAPI()
                )
                .register(
                    module: MockModule.self
                )
                .start()
                .store
                .dispatch(
                    TestAction.fetch
                )
        }
    }
    
}

extension ManagerTests {
    
    func testRegisterReducer() {
        waitUntil { done in
            Manager()
                .register(
                    reducer: { (action: TestAction, state) in
                        expect(action) == .start
                        done()
                        return state.with {
                            $0["some"] = TestState()
                        }
                    }
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
}

extension ManagerTests {
    
    func testRegisterMiddleware() {
        waitUntil { done in
            Manager()
                .register(
                    middleware: MockMiddleware { action in
                        guard case TestAction.start = action else { return }
                        done()
                    }
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterMiddlewares() {
        waitUntil { done in
            var number = 0
            Manager()
                .register(
                    middlewares: [
                        MockMiddleware { action in
                            guard case TestAction.start = action else { return }
                            number += 1
                        },
                        MockMiddleware { action in
                            guard case TestAction.start = action else { return }
                            expect(number) == 1
                            done()
                        }
                    ]
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterMiddlewaresWithPriorities() {
        waitUntil { done in
            var number = 0
            Manager()
                .register(
                    middleware: MockMiddleware { action in
                        guard case TestAction.start = action else { return }
                        expect(number) == 2
                        done()
                    },
                    priority: .low
                )
                .register(
                    middleware: MockMiddleware { action in
                        guard case TestAction.start = action else { return }
                        expect(number) == 1
                        number += 1
                    },
                    priority: .medium
                )
                .register(
                    middleware: MockMiddleware { action in
                        guard case TestAction.start = action else { return }
                        expect(number) == 0
                        number += 1
                    },
                    priority: .high
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterMiddlewareAsFunction() {
        waitUntil { done in
            Manager()
                .register(
                    middleware: MockMiddleware.asFunction { action in
                        guard case TestAction.start = action else { return }
                        done()
                    }
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterMiddlewaresAsFunctions() {
        waitUntil { done in
            var number = 0
            Manager()
                .register(
                    middlewares: [
                        MockMiddleware.asFunction { action in
                            guard case TestAction.start = action else { return }
                            number += 1
                        },
                        MockMiddleware.asFunction { action in
                            guard case TestAction.start = action else { return }
                            expect(number) == 1
                            done()
                        }
                    ]
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterMiddlewaresAsFunctionsWithPriorities() {
        waitUntil { done in
            var number = 0
            Manager()
                .register(
                    middleware: MockMiddleware.asFunction { action in
                        guard case TestAction.start = action else { return }
                        expect(number) == 2
                        done()
                    },
                    priority: .low
                )
                .register(
                    middleware: MockMiddleware.asFunction { action in
                        guard case TestAction.start = action else { return }
                        expect(number) == 1
                        number += 1
                    },
                    priority: .medium
                )
                .register(
                    middleware: MockMiddleware.asFunction { action in
                        guard case TestAction.start = action else { return }
                        expect(number) == 0
                        number += 1
                    },
                    priority: .high
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
}

extension ManagerTests {
    
    func testRegisterModuleMapper() {
        waitUntil { done in
            Manager()
                .register(
                    moduleMapper: { action in
                        guard case TestAction.start = action else { return nil }
                        done()
                        return [
                            .start(MockModule.self)
                        ]
                    } as ModuleMapper
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterModuleMapperSingleReturn() {
        waitUntil { done in
            Manager()
                .register(
                    moduleMapper: { action in
                        guard case TestAction.start = action else { return nil }
                        done()
                        return .start(MockModule.self)
                    } as ModuleMapperSingleReturn
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterModuleStarter() {
        waitUntil { done in
            Manager()
                .register(
                    moduleMapper: { action in
                        guard case TestAction.start = action else { return nil }
                        done()
                        return [MockModule.self]
                    } as ModuleStarter
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
    func testRegisterModuleStarterSingleReturn() {
        waitUntil { done in
            Manager()
                .register(
                    moduleMapper: { action in
                        guard case TestAction.start = action else { return nil }
                        done()
                        return MockModule.self
                    } as ModuleStarterSingleReturn
                )
                .start()
                .store
                .dispatch(
                    TestAction.start
                )
        }
    }
    
}
