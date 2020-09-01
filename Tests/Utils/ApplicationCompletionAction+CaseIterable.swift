//
//  ApplicationCompletionAction+CaseIterable.swift
//  Tests
//
//  Created by Luciano Polit on 9/1/20.
//  Copyright © 2020 LucianoPolit. All rights reserved.
//

import Foundation
import Caesura

extension ApplicationCompletionAction: CaseIterable {
    
    public static let allCases: [ApplicationCompletionAction] = [
        .didFinishLaunching,
        .didEnterBackground,
        .willEnterForeground,
        .didBecomeActive,
        .willResignActive,
        .userDidTakeScreenshot,
        .didReceiveMemoryWarning,
        .willTerminate
    ]
    
}
