//
//  NavigationAction+StandardAction.swift
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
import StandardAction
#endif

extension NavigationCompletionAction: StandardActionConvertible {
    
    public static var key: String {
        return NavigationAction.key
    }
    
    public init(
        action: StandardAction
    ) throws {
        fatalError("init(action:) has not been implemented")
    }
    
    public func toStandard() -> StandardAction? {
        switch self {
        case .start,
             .set, .present,
             .setNavigation, .push,
             .setTabs, .insertTab, .removeTab:
            return nil
        case .dismiss(_, let origin):
            return origin == .user ?
                StandardAction(name: NavigationCodingKeys.dismiss.rawValue) : nil
        case .pop(_, let origin):
            return origin == .user ?
                StandardAction(name: NavigationCodingKeys.pop.rawValue) : nil
        case .selectTab(_, let index, _, _, let origin):
            return origin == .user ?
                StandardAction(name: NavigationCodingKeys.selectTab.rawValue, payload: index) : nil
        }
    }
    
}

extension NavigationAction: StandardActionConvertible {
    
    public init(
        action: StandardAction
    ) throws {
        guard let key = NavigationCodingKeys(rawValue: action.name)
            else { throw StandardActionError.keyNotFound }
        switch key {
        case .dismiss: self = .dismiss(animated: false)
        case .pop: self = .pop(animated: false)
        case .selectTab: try self = .selectTabAtIndex(action.decodedPayload(), animated: false)
        }
    }
    
    public func toStandard() -> StandardAction? {
        return nil
    }
    
}

private enum NavigationCodingKeys: String {
    case dismiss
    case pop
    case selectTab
}
