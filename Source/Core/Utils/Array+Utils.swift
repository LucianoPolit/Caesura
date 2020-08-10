//
//  Array+Utils.swift
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

extension Collection {
    
    subscript(
        safe index: Index
    ) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}

extension Array {
    
    mutating func prepend(
        _ element: Element
    ) {
        insert(element, at: 0)
    }
    
    mutating func prepend(
        contentsOf array: [Element]
    ) {
        insert(contentsOf: array, at: 0)
    }
    
}

extension Array where Element: Equatable {
    
    mutating func remove(
        _ element: Element
    ) {
        while remove(firstAppearanceOf: element) { }
    }
    
    @discardableResult
    mutating func remove(
        firstAppearanceOf element: Element
    ) -> Bool {
        guard let index = firstIndex(of: element) else { return false }
        remove(at: index)
        return true
    }
    
}

extension Array {
    
    func prepending(
        _ value: Element
    ) -> [Element] {
        var copy = self
        copy.prepend(value)
        return copy
    }
    
    func prepending(
        contentsOf value: [Element]
    ) -> [Element] {
        var copy = self
        copy.prepend(contentsOf: value)
        return copy
    }
    
    func inserting(
        _ value: Element,
        at index: Int
    ) -> [Element] {
        var copy = self
        copy.insert(value, at: index)
        return copy
    }
    
    func inserting(
        contentsOf value: [Element],
        at index: Int
    ) -> [Element] {
        var copy = self
        copy.insert(contentsOf: value, at: index)
        return copy
    }
    
    func appending(
        _ value: Element
    ) -> [Element] {
        var copy = self
        copy.append(value)
        return copy
    }
    
    func appending(
        contentsOf value: [Element]
    ) -> [Element] {
        var copy = self
        copy.append(contentsOf: value)
        return copy
    }
    
    func removing(
        at index: Int
    ) -> [Element] {
        var copy = self
        copy.remove(at: index)
        return copy
    }
    
}

extension Array where Element: Equatable {
    
    func removing(
        _ value: Element
    ) -> [Element] {
        var copy = self
        while let index = copy.firstIndex(where: { $0 == value }) {
            copy.remove(at: index)
        }
        return copy
    }
    
    func removing(
        contentsOf value: [Element]
    ) -> [Element] {
        var copy = self
        value.forEach {
            copy = copy.removing($0)
        }
        return copy
    }
    
}
