//
//  AdMobIntertstitialManager.swift
//  AdMobCardAdapter
//
//  Created by Jerome TONNELIER on 28/04/2025.
//

import GoogleMobileAds
import AdsCardAdapter
import AdsCardLibrary

class AdMobRewardedManager: AdMobManager {
    var ad: RewardedAd?
    
    override func instanciateAd() async {
        // with AdMob, the ad is returned from the load
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func load() async {
        await super.load()
        do {
            ad = try await RewardedAd.load(with: adType.adUnit, request: Request())
            ad?.fullScreenContentDelegate = proxy
        } catch {
            append(.adDidFailToLoad(error))
        }
        
    }
    
    override func show() {
        guard let viewController else { return }
        ad?.present(from: viewController) { [weak self] in
            self?.append(.rewardReady(name: self?.ad?.adReward.description ?? "n/a",
                                      value: "\(self?.ad?.adReward.amount ?? 0)"))
        }
    }
}
