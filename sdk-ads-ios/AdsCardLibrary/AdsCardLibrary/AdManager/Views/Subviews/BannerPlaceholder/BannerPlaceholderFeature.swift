//
//  MrecPlaceholderFeature.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import ComposableArchitecture
import OguryAds

struct BannerPlaceholderFeature: Reducer {
    struct State: Equatable {
        var bannerAd: UIView? = nil
        var bannerType: AdType<BannerAdManager>
        var isMpuFormat: Bool {
            switch bannerType {
                case .mpu,
                     .maxHeaderBidding(.mpu, _),
                     .dtFairBidHeaderBidding(.mpu, _),
                     .unityLevelPlayHeaderBidding(.mpu, _):
                    return true
                default: return false
            }
        }
    }
    
    enum Action: Equatable {
        case closeButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
