//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import OguryAds

class AdDelegateProxy<T: AdManager>: NSObject {
   internal var adDelegate: AdLifeCycleDelegate?
   internal var adManager: T? // optionnal to make it weak
   internal init(adDelegate: AdLifeCycleDelegate? = nil) {
      super.init()
      self.adDelegate = adDelegate
   }
   
   internal func handle(_ error: Error, for ad: T.Ad) {
      guard let adManager else { return }
      guard let error = error as? OguryError else {
         adManager.append(.adDidFail(error))
         return
      }
      
      switch error.code {
         case OguryAdsErrorType.invalidConfiguration.rawValue,
            OguryAdsErrorType.noAdLoaded.rawValue:
            adManager.append(.adDidFailToLoad(error))
            
         case OguryAdsErrorType.adExpired.rawValue,
            OguryAdsErrorType.anotherAdIsAlreadyDisplayed.rawValue,
            OguryAdsErrorType.viewControllerPreventsAdFromBeingDisplayed.rawValue:
            adManager.append(.adDidFailToDisplay(error))
            
         default:
            adManager.append(.adDidFail(error))
      }
   }
}

extension String {
    static var sdkVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "n/a")
        + ".b\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey! as String) as? String ?? "n/a")"
    }
}
