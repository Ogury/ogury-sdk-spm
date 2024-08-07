//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

import UIKit

protocol AdsFullscreenController: AdController {

    func load(adUnitId: String, campaignId: String?, creativeId:String?, dspCreativeId: String?, dspRegion: String?)
    
    func show(in viewController: UIViewController)
    
    func loadAndShow(adUnitId: String, campaignId: String?, creativeId:String?, dspCreativeId: String?, dspRegion: String?, in viewController: UIViewController)
    
    func isLoaded() -> Bool
    
    // to remove once deprecated classes are removed
    func loadAndShow(adUnitId: String, campaignId: String?, in viewController: UIViewController)
    
    // to remove once dprecated classes are removed
    func load(adUnitId: String, campaignId: String?)
}

// default implementation for optionnal methods
extension AdsFullscreenController {
    
    func loadAndShow(adUnitId: String, campaignId: String?, in viewController: UIViewController) {
        // do nothing
    }
    
    func load(adUnitId: String, campaignId: String?) {
        // do nothing
    }
    
}
