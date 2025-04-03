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
        var bannerType: AdFormat
        var isMrec: Bool { bannerType == .mrec }
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
