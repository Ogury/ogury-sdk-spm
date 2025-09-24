//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import Foundation

enum Environment: CaseIterable {
    case devc, staging, prod, beta, release
    
    var name: String {
        return "\(self)"
    }
    
    var assetKey: String {
        switch self {
        case .devc:
            return "271399"
        case .staging:
            return "272506"
        case .prod, .beta, .release:
            return "315524"
        }
    }
    
    var interstitialAdUnitId: String {
        switch self {
        case .devc:
            return "271399_default"
        case .staging:
            return "272506_default"
        case .prod, .beta, .release:
            return "315524_default_test"
        }
    }
}

func getEnvironment() -> Environment {
    guard let oguryEnvironment = Bundle.main.object(forInfoDictionaryKey: "OguryEnvironment") as! String? else {
        fatalError("Missing OguryEnvironment in test application Info.plist.")
    }
    for environment in Environment.allCases {
        if environment.name == oguryEnvironment {
            return environment
        }
    }
    fatalError(String(format: "Environment %@ does not exists.", oguryEnvironment))
}
