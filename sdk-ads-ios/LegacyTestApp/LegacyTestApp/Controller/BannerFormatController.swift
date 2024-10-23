//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import UIKit
import OguryAds

protocol BannerFormatController: FormatController {

    // to remove once deprecated classes are removed
    func load(adUnitId: String, campaignId: String?, maxSize: OguryBannerAdSize, inView view: UIView?, withWidth width: CGFloat?)
    
    func load(adUnitId: String, campaignId: String?, creativeId:String?, dspCreativeId: String?, dspRegion: String?, maxSize: OguryBannerAdSize, inView view: UIView?, withWidth width: CGFloat?)
    
    func isLoaded() -> Bool
}

// default implementation for optionnal methods
extension BannerFormatController {
    
    func load(adUnitId: String, campaignId: String?, maxSize: OguryBannerAdSize, inView view: UIView?, withWidth width: CGFloat?) {
        // do nothing
    }
    
}
