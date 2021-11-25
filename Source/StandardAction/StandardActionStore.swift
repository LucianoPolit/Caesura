//
//  StandardActionStore.swift
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

public class StandardActionStore {
    
    public static let `default` = StandardActionStore(
        key: "StandardActionStoreKey",
        fileBaseName: "recording"
    )
    
    public var dateFormatter = ISO8601DateFormatter()
    public private(set) var types: [StandardActionConvertible.Type] = []
    public let key: String
    public let fileBaseName: String
    public private(set) var currentIdentifier: Int {
        get {
            return UserDefaults.standard.integer(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    public init(
        key: String,
        fileBaseName: String
    ) {
        self.key = key
        self.fileBaseName = fileBaseName
    }
    
    public func register(
        actionType type: Action.Type
    ) {
        guard let type = type as? StandardActionConvertible.Type else { return }
        types.append(type)
    }
    
}

extension StandardActionStore {
    
    public func save(
        _ actionsAndKeys: [(StandardAction, String, Date)]
    ) throws {
        currentIdentifier += 1
        let source = try actionsAndKeys.map(toJSON)
        let data = try JSONSerialization.data(
            withJSONObject: source,
            options: .prettyPrinted
        )
        try data.write(
            to: directory(
                forIdentifier: currentIdentifier
            ),
            options: [.atomic]
        )
    }
    
    public func eraseLastSaving() throws {
        try remove(
            at: directory(
                forIdentifier: currentIdentifier
            )
        )
        currentIdentifier -= 1
    }
    
    public func load(
        _ identifier: Int? = nil
    ) throws -> [Action] {
        return try loadActions(
            from: loadData(identifier ?? currentIdentifier)
        )
    }
    
}

extension StandardActionStore {
    
    public func loadFromResources() throws -> [Action] {
        guard
            let path = Bundle.main.path(
                forResource: fileBaseName,
                ofType: "json"
            )
            else { return [] }
        return try loadActions(
            from: Data(
                contentsOf: URL(
                    fileURLWithPath: path
                )
            )
        )
    }
    
}

extension StandardActionStore {
    
    public func loadData(
        _ identifier: Int
    ) throws -> Data {
        return try Data(
            contentsOf: directory(
                forIdentifier: identifier
            )
        )
    }
    
}

private extension StandardActionStore {
    
    func loadActions(
        from data: Data
    ) throws -> [Action] {
        return try toActions(
            from: JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
            )
        )
    }
    
}

private extension StandardActionStore {
    
    func remove(
        at url: URL
    ) throws {
        try FileManager.default.removeItem(at: url)
    }
    
}

private extension StandardActionStore {
    
    func directory(
        forIdentifier identifier: Int
    ) throws -> URL {
        return try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(
            fileName(forIdentifier: identifier)
        )
    }
    
    func fileName(
        forIdentifier identifier: Int
    ) -> String {
        return "\(fileBaseName)-\(identifier)"
    }
    
}

private extension StandardActionStore {
    
    func toJSON(
        from standardAction: StandardAction,
        key: String,
        date: Date
    ) throws -> [String: Any] {
        var dictionary: [String: Any] = [
            "key": key,
            "name": standardAction.name,
            "date": dateFormatter.string(from: date)
        ]
        
        if let payload = standardAction.payload {
            dictionary["payload"] = try JSONSerialization.jsonObject(
                with: payload,
                options: .allowFragments
            )
        }
        
        return dictionary
    }
    
    func toActions(
        from json: Any
    ) -> [Action] {
        guard let array = json as? [[String: Any]] else { return [] }
        return array.compactMap {
            guard let key = $0["key"] as? String,
                let name = $0["name"] as? String
                else { return nil }

            do {
                guard let type = types.first(where: { $0.key == key })
                    else { throw StandardActionError.keyNotFound }
                
                var payload: Data?
                if let jsonPayload = $0["payload"] {
                    payload = try JSONSerialization.data(
                        withJSONObject: jsonPayload,
                        options: .fragmentsAllowed
                    )
                }
                
                return try type.init(
                    action: StandardAction(
                        name: name,
                        payload: payload
                    )
                )
            } catch {
                print("Action not mapped: \(key).\(name)")
                return nil
            }
        }
    }
    
}
