//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import Foundation

enum Environment: CaseIterable {
    case prod
    case staging
    case devC

    var configName: String {
        switch self {
        case .prod: return "production"
        case .staging: return "staging"
        case .devC: return "devc"
        }
    }
}
