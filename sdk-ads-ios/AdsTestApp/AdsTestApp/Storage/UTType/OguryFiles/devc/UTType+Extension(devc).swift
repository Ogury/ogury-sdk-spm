//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    // Define a custom UTI for a hypothetical custom document type
    static var adsTestAppType: UTType {
        return UTType(exportedAs: "co.ogury.sdk.ads.devc.exportedSet")
    }
    static var adsTestAppExtension: String { "ogad" }
}
