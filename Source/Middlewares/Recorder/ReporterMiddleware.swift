//
//  ReporterMiddleware.swift
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

public class ReporterMiddleware: Middleware {
    
    public let store: StandardActionStore
    public let outputMode: OutputMode
    public let outputHandler: ([Data]) -> Void

    public init(
        store: StandardActionStore = .default,
        outputMode: OutputMode = .last(1),
        outputHandler: @escaping ([Data]) -> Void
    ) {
        self.store = store
        self.outputMode = outputMode
        self.outputHandler = outputHandler
    }
    
    public func intercept(
        dispatch: @escaping DispatchFunction,
        state: @escaping () -> State?
    ) -> MiddlewareReturnType {
        return { next in
            return { action in
                self.handle(
                    action: action
                )
                next(action)
            }
        }
    }
    
}

extension ReporterMiddleware {
    
    public enum OutputMode {
        case all
        case last(Int)
    }
    
}

private extension ReporterMiddleware {
    
    func handle(
        action: Action
    ) {
        guard case CrashDetectorCompletionAction.didCrash = action else { return }
        let lowerBound: Int = {
            switch outputMode {
            case .all: return 0
            case .last(let amount): return store.currentIdentifier - amount
            }
        }()
        guard lowerBound < store.currentIdentifier else { return }
        
        var output: [Data] = []
        for id in lowerBound ... store.currentIdentifier {
            guard let data = try? store.loadData(id) else { continue }
            output.append(data)
        }
        outputHandler(output)
    }
    
}
