//
//  CardPermissions.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 31/01/2025.
//

import SwiftUI

public struct CardPermissions {
    let logs: Bool
    let add: Bool
    let devFeatures: Bool
    
    public init(logs: Bool = true, add: Bool = true, devFeatures: Bool = true) {
        self.logs = logs
        self.add = add
        self.devFeatures = devFeatures
    }
    
    var showCardMenu: Bool {
        logs || devFeatures
    }
}

public struct CardPermissionsKey: EnvironmentKey {
    public static var defaultValue: CardPermissions = CardPermissions()
}

public extension EnvironmentValues {
    var cardPermissions: CardPermissions {
        get { self[CardPermissionsKey.self] }
        set { self[CardPermissionsKey.self] = newValue }
    }
}
