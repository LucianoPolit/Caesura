//
//  StandardAction.swift
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
import ReSwift
#endif

public enum StandardActionError: Error {
    case missingParameter
    case keyNotFound
}

public struct StandardAction: Action {
    
    public let name: String
    public let payload: Data?
    
    public init(
        name: String,
        payload: Data? = nil
    ) {
        self.name = name
        self.payload = payload
    }
    
    public init<T: Encodable>(
        name: String,
        payload: T
    ) {
        self.init(
            name: name,
            payload: try? PayloadEncoder(
                encodable: payload
            ).encode()
        )
    }
    
    public func decodedPayload<T: Decodable>(
        type: T.Type = T.self
    ) throws -> T {
        return try PayloadDecoder(
            data: payload
        ).decode()
    }
    
}

private extension StandardAction {
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    
    class PayloadEncoder<T: Encodable> {
        
        let encodable: T?
        
        init(
            encodable: T?
        ) {
            self.encodable = encodable
        }
        
        func encode() throws -> Data {
            guard let encodable = encodable else { throw StandardActionError.missingParameter }
            return try jsonEncoder.encode([encodable])
        }
        
    }
    
    class PayloadDecoder {
        
        let data: Data?
        
        init(
            data: Data?
        ) {
            self.data = data
        }
        
        func decode<T: Decodable>(
            type: T.Type = T.self
        ) throws -> T {
            guard let data = data else { throw StandardActionError.missingParameter }
            let decodedArray = try jsonDecoder.decode([T].self, from: data)
            guard let decoded = decodedArray.first else { throw StandardActionError.missingParameter }
            return decoded
        }
        
    }
    
}
