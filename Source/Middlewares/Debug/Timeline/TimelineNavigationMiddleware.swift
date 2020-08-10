//
//  TimelineNavigationMiddleware.swift
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

public class TimelineNavigationMiddleware: DebugMiddleware {
    
    private var indexesAndActions: [(Int, NavigationCompletionAction)] = []
    private var memory = 0
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
                    next: next,
                    dispatch: dispatch
                )
                next(action)
            }
        }
    }
    
}

private extension TimelineNavigationMiddleware {
    
    func handle(
        action: Action,
        next: DispatchFunction,
        dispatch: DispatchFunction
    ) {
        guard !ignore else {
            ignore = false
            return
        }
        
        if let navigationAction = (action as? NavigationCompletionAction)?.justImportant() {
            if let index = indexesAndActions.firstIndex(where: { $0.0 == memory }) {
                indexesAndActions.remove(at: index)
            }
            indexesAndActions.append((memory, navigationAction))
        }
        
        if let timelineAction = action as? TimelineCompletionAction {
            switch timelineAction {
            case .total(let total):
                indexesAndActions = indexesAndActions.filter { $0.0 < total }
            case .current(let current):
                memory = current
            case .back:
                handleBack {
                    dispatch(TimelineAction.ignore)
                    next($0)
                }
            case .forward:
                handleForward {
                    dispatch(TimelineAction.ignore)
                    next($0)
                }
            case .ignore:
                ignore = true
            }
        }
    }
    
}

private extension TimelineNavigationMiddleware {
    
    func handleBack(
        _ dispatch: DispatchFunction
    ) {
        let index = memory - 1
        guard let action = indexesAndActions.first(where: { $0.0 == index })?.1 else { return }
        requiredActions(
            toRevert: action,
            index: index
        ).forEach(dispatch)
    }
    
    func handleForward(
        _ dispatch: DispatchFunction
    ) {
        let index = memory
        guard let action = indexesAndActions.first(where: { $0.0 == index })?.1 else { return }
        dispatch(action.toNavigation())
    }
    
}

private extension TimelineNavigationMiddleware {
    
    func requiredActions(
        toRevert action: NavigationCompletionAction,
        index: Int
    ) -> [NavigationAction] {
        switch action {
        case .start:
            return []
        case .set(_, let previousViewController):
            return [.set(previousViewController)]
        case .present:
            return [.dismiss(animated: false)]
        case .dismiss:
            return requiredActions(toRevertDismissAt: index)
        case .setNavigation(_, let previousViewControllers):
            return [.setNavigation(to: previousViewControllers, animated: false)]
        case .push:
            return [.pop(animated: false)]
        case .pop:
            return requiredActions(toRevertPopAt: index)
        case .setTabs(_, let previousViewControllers):
            return [.setTabs(previousViewControllers, animated: false)]
        case .insertTab(let viewController, _):
            return [.removeTab(viewController, animated: false)]
        case .removeTab(let viewController, let index):
            return [.insertTab(viewController, at: .index(index), animated: false)]
        case .selectTab(_, _, let previousViewController, _, _):
            return [.selectTab(previousViewController, animated: false)]
        }
    }
    
}

private extension TimelineNavigationMiddleware {
    
    func requiredActions(
        toRevertDismissAt index: Int
    ) -> [NavigationAction] {
        var actions: [NavigationAction] = []
        var totalPresent = 1
        
        for i in (0 ..< index).reversed() {
            if let action = indexesAndActions.first(where: { $0.0 == i })?.1 {
                if case .dismiss = action {
                    totalPresent += 1
                }
                
                if case .present = action {
                    totalPresent -= 1
                }
                
                guard totalPresent == 0 else { continue }
                actions.append(action.toNavigation())
                break
            }
        }
        
        return actions.reversed()
    }
    
    func requiredActions(
        toRevertPopAt index: Int
    ) -> [NavigationAction] {
        var actions: [NavigationAction] = []
        var totalPresent = 0
        var totalPush = 1
        
        for i in (0 ..< index).reversed() {
            if let action = indexesAndActions.first(where: { $0.0 == i })?.1 {
                if case .dismiss = action {
                    totalPresent += 1
                }
                
                if case .pop = action, totalPresent == 0 {
                    totalPush += 1
                }
                
                if case .present = action {
                    totalPresent -= 1
                }
                
                if case .push = action, totalPresent == 0 {
                    totalPush -= 1
                }
                
                guard totalPush == 0 else { continue }
                actions.append(action.toNavigation())
                break
            }
        }
        
        return actions.reversed()
    }
    
}

private extension NavigationCompletionAction {
    
    func justImportant() -> NavigationCompletionAction? {
        switch self {
        case .start:
            return nil
        case .set, .present, .dismiss,
             .setNavigation, .push, .pop,
             .setTabs, .insertTab, .removeTab, .selectTab:
            return self
        }
    }
    
}

private extension NavigationCompletionAction {
    
    func toNavigation() -> NavigationAction {
        switch self {
        case .start:
            return .start
        case .set(let viewController, _):
            return .set(viewController)
        case .present(let viewController):
            return .present(viewController, animated: false)
        case .dismiss:
            return .dismiss(animated: false)
        case .setNavigation(let viewControllers, _):
            return .setNavigation(to: viewControllers, animated: false)
        case .push(let viewController):
            return .push(viewController, animated: false)
        case .pop:
            return .pop(animated: false)
        case .setTabs(let viewControllers, _):
            return.setTabs(viewControllers, animated: false)
        case .insertTab(let viewController, let index):
            return .insertTab(viewController, at: .index(index), animated: false)
        case .removeTab(let viewController, _):
            return .removeTab(viewController, animated: false)
        case .selectTab(let viewController, _, _, _, _):
            return .selectTab(viewController, animated: false)
        }
    }
    
}
