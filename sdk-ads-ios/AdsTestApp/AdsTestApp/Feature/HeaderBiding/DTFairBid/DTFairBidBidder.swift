//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import AdsCardLibrary
import OguryAds

class DTFairBidBidder: RTBBidder, DTFairBidHeaderBidable {
    override var url: URL! { Configuration.shared.dtFairBidOptions.url }
    override func updateJson(withAdUnit adUnit: String, assetKey: String, country: String?, token: String?) {
        super.updateJson(withAdUnit: adUnit, assetKey: assetKey, country: country, token: token)
        body.imp[0].displaymanager = Configuration.shared.dtFairBidOptions.displayManager!
        body.user.data[0].segment[0] = ["signal" : token ?? ""]
    }
    
    override func adMarkUp(from response: HeaderBiddingBid) -> String? {
        response.ext?.signaldata
    }
}
