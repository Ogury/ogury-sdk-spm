//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    // Define a custom UTI for a hypothetical custom document type
    static var oguryAds: UTType {
        return UTType(exportedAs: "co.ogury.sdk.ads.prod.exportedSet")
    }
    static var oguryAdsExtension: String { "ogap" }
}
