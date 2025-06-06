//
//  MrecPlaceholderFeature.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
internal import ComposableArchitecture

@Reducer
struct BannerPlaceholderFeature {
    
    @ObservableState
    struct State: Equatable {
        var adManager: any AdManager
        var bannerAd: UIView? = nil
        var ratio: CGFloat { (250 / 300) }
        var availableSizes: [BannerSize]
        var actualSizeId: BannerSize.ID
        var actualSize: BannerSize
        
        init(adManager: any AdManager, bannerAd: UIView? = nil, actualSize: BannerSize? = nil) {
            self.adManager = adManager
            self.bannerAd = bannerAd
            
            let sizes = adManager.bannerSizes ?? []
            self.availableSizes = sizes
            
            let size = actualSize == nil
            ? (sizes.first ?? BannerSize.init(size: .zero, image: Image(systemName:"platter.filled.bottom.iphone")))
            : actualSize!
            self.actualSize = size
            self.actualSizeId = size.id
            print("🐳 actualSize \(size.description)")
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.adManager.id == rhs.adManager.id
            && lhs.availableSizes == rhs.availableSizes
            && lhs.actualSizeId == rhs.actualSizeId
            && ((lhs.bannerAd == nil && rhs.bannerAd == nil) || (lhs.bannerAd != nil && rhs.bannerAd != nil))
        }
    }
    
    enum Action: Equatable {
        case closeButtonTapped
        case pickedSize(_: BannerSize)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .closeButtonTapped:
                    return .none
                    
                case let .pickedSize(size):
                    state.actualSize = size
                    state.adManager.updateBannerSize(size)
                    return .none
            }
        }
    }
}
