//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryAds

protocol ThumbnailController: AdController {
    
    func load(adUnitId: String, campaignId: String?, creativeId: String?, dspCreativeId: String?, dspRegion: String?, maxSize: CGSize?)
    
    func loadAndShow(adUnitId: String, campaignId: String?, creativeId: String?, dspCreativeId: String?, dspRegion: String?, maxSize: CGSize?, showAt: CGPoint?, withCorner corner: OguryRectCorner?)
    
    func show(at point: CGPoint?, withCorner corner: OguryRectCorner?)
    
    func isLoaded() -> Bool

}

extension ThumbnailController {
    
    func loadAndShow(adUnitId: String, campaignId: String?, creativeId: String?, dspCreativeId: String?, dspRegion: String?, maxSize: CGSize? = nil, showAt: CGPoint? = nil) {
        loadAndShow(adUnitId: adUnitId, campaignId: campaignId, creativeId: creativeId, dspCreativeId: dspCreativeId, dspRegion: dspRegion, maxSize: maxSize, showAt: showAt, withCorner: nil)
    }
    
    func show(at point: CGPoint? = nil) {
        show(at: point, withCorner: nil)
    }
    
}
