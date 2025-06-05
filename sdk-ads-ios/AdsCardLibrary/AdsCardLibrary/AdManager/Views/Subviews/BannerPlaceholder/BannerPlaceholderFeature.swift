//
//  MrecPlaceholderFeature.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
internal import ComposableArchitecture

struct BannerPlaceholderFeature: Reducer {
    
    struct State: Equatable {
        var adManager: any AdManager
        var bannerAd: UIView? = nil
        var ratio: CGFloat { (250 / 300) }
        var availableSizes: [BannerSize]
        var actualSize: BannerSize
        
        init(adManager: any AdManager, bannerAd: UIView? = nil, actualSize: BannerSize? = nil) {
            self.adManager = adManager
            self.bannerAd = bannerAd
            let sizes = adManager.bannerSizes ?? []
            self.availableSizes = sizes
            self.actualSize = actualSize == nil
            ? (sizes.first ?? BannerSize.init(size: .zero, image: Image(systemName:"platter.filled.bottom.iphone")))
            : actualSize!
            print("🐳 actualSize: \(self.actualSize.description)")
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.adManager.id == rhs.adManager.id
            && lhs.availableSizes == rhs.availableSizes
            && lhs.actualSize == rhs.actualSize
            && ((lhs.bannerAd == nil && rhs.bannerAd == nil) || (lhs.bannerAd != nil && rhs.bannerAd != nil))
        }
    }
    
    enum Action: Equatable {
        case closeButtonTapped
        case sizePicked(_: BannerSize)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .closeButtonTapped:
                    return .none
                    
                case let .sizePicked(size):
                    state.actualSize = size
                    return .none
            }
        }
    }
}
