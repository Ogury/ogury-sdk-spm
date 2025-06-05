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
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case closeButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.actualSizeId) { oldValue, newValue in
                Reduce() { state, action in
                    state.actualSize = state.availableSizes.first(where: { $0.id == newValue })!
                    state.adManager.updateBannerSize(state.actualSize)
                    return .none
                }
            }
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                    
                case .closeButtonTapped:
                    return .none
            }
        }
    }
}
