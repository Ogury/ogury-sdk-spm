//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import AdsCardLibrary
import OguryAds

class DTFairBidBidder: RTBBidder {
    override var url: URL! { configuration.dtFairBidOptions.url }
    override func updateJson(withAdUnit adUnit: String,
                             assetKey: String,
                             country: String?,
                             token: String?,
                             rtbTestModeEnabled: Bool) {
        super.updateJson(withAdUnit: adUnit, assetKey: assetKey, country: country, token: token, rtbTestModeEnabled: rtbTestModeEnabled)
        body.imp[0].displaymanager = configuration.dtFairBidOptions.displayManager!
        body.user.data[0].segment[0] = ["signal" : token ?? ""]
    }
    
    override func adMarkUp(from response: HeaderBiddingBid) -> String? {
        response.ext?.signaldata
    }
}
