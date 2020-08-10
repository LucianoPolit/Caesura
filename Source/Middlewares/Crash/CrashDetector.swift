//
//  CrashDetector.swift
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

class CrashDetector {
    
    private static var handler: (() -> Void)?
    private static let signals = [
        SIGABRT,
        SIGILL,
        SIGSEGV,
        SIGFPE,
        SIGBUS,
        SIGPIPE,
        SIGTRAP
    ]
    
    static func start(
        with handler: @escaping () -> Void
    ) {
        CrashDetector.handler = handler
        signals.forEach { signal($0, handleSignal) }
        NSSetUncaughtExceptionHandler(handleException)
    }
    
}

private extension CrashDetector {
    
    private static let handleException: @convention(c) (NSException) -> Void = { _ in
        handleCrash()
    }
    
    private static let handleSignal: @convention(c) (Int32) -> Void = { _ in
        handleCrash()
    }
    
}

private extension CrashDetector {
    
    private static func handleCrash() {
        CrashDetector.handler?()
        signals.forEach { signal($0, SIG_DFL) }
        NSSetUncaughtExceptionHandler(nil)
        kill(getpid(), SIGKILL)
    }
    
}
