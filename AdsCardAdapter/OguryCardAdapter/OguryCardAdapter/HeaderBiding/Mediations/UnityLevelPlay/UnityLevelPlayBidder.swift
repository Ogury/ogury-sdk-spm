//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import AdsCardLibrary
import OguryAds

class UnityLevelPlayBidder: RTBBidder {
    override var url: URL! { configuration.unityLevelPlayOptions.url }
    override func updateJson(withAdUnit adUnit: String,
                             assetKey: String,
                             country: String?,
                             token: String?,
                             rtbTestModeEnabled: Bool) {
        super.updateJson(withAdUnit: adUnit, assetKey: assetKey, country: country, token: token, rtbTestModeEnabled: rtbTestModeEnabled)
        body.imp[0].displaymanager = configuration.unityLevelPlayOptions.displayManager!
        body.app.ext = ["token" : token ?? ""]
    }
    
    override func adMarkUp(from response: HeaderBiddingBid) -> String? {
        response.adm
    }
}
