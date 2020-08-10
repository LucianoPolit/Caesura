//
//  APIActionDispatcher.swift
//  List
//
//  Created by Luciano Polit on 8/16/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura
import API

class APIActionDispatcher: Caesura.APIActionDispatcher<Action> {
    
    let exampleClient: ExampleClient
    
    init(
        exampleClient: ExampleClient
    ) {
        self.exampleClient = exampleClient
    }
    
    override func dispatch(
        _ action: ActionType,
        to destination: @escaping Destination
    ) -> Bool {
        switch action {
        case .fetch: handleFetch(with: destination)
        default: return super.dispatch(action, to: destination)
        }
        return true
    }
    
}

extension APIActionDispatcher {
    
    func handleFetch(
        with destination: @escaping Destination
    ) {
        destination(.loading)
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1
        ) {
            destination(.set(["First", "Second", "Third"]))
        }
    }
    
//    func handleFetch(
//        with destination: @escaping Destination
//    ) {
//        handle(
//            request: exampleClient.readAll,
//            loading: ActionType.loading,
//            success: ActionType.set,
//            failure: ActionType.error,
//            destination: destination
//        )
//    }
    
}
