//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import AdsCardLibrary
import OguryAds

class UnityLevelPlayBidder: RTBBidder, UnityLevelPlayBidable {
    override var url: URL! { Configuration.shared.unityLevelPlayOptions.url }
    override func updateJson(withAdUnit adUnit: String,
                             assetKey: String,
                             country: String?,
                             token: String?,
                             rtbTestModeEnabled: Bool) {
        super.updateJson(withAdUnit: adUnit, assetKey: assetKey, country: country, token: token, rtbTestModeEnabled: rtbTestModeEnabled)
        body.imp[0].displaymanager = Configuration.shared.unityLevelPlayOptions.displayManager!
        body.app.ext = ["token" : token ?? ""]
    }
    
    override func adMarkUp(from response: HeaderBiddingBid) -> String? {
        response.adm
    }
}
