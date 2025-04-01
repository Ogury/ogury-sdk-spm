//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import AdsCardLibrary


struct AdFormat: Equatable, Identifiable, Hashable {
    let id: Int
    var title: String {
        if let ad = (adType.adType as? AdType<InterstitialAdManager>) {
            return ad.headerTitle
        }
        if let ad = (adType.adType as? AdType<RewardedAdManager>) {
            return ad.headerTitle
        }
        if let ad = (adType.adType as? AdType<ThumbnailAdManager>) {
            return ad.headerTitle
        }
        if let ad = (adType.adType as? AdType<BannerAdManager>) {
            return ad.headerTitle
        }
        return ""
    }
    var addCardTitle: String {
        if let ad = (adType.adType as? AdType<InterstitialAdManager>) {
            return ad.displayTitle
        }
        if let ad = (adType.adType as? AdType<RewardedAdManager>) {
            return ad.displayTitle
        }
        if let ad = (adType.adType as? AdType<ThumbnailAdManager>) {
            return ad.displayTitle
        }
        if let ad = (adType.adType as? AdType<BannerAdManager>) {
            return ad.displayTitle
        }
        return ""
    }
    let adType: AnyAdType
    var nbOfFormatToLoad = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdFormat, rhs: AdFormat) -> Bool {
        lhs.id == rhs.id && lhs.nbOfFormatToLoad == rhs.nbOfFormatToLoad
    }
    
    internal var innerAdType: Int {
        get throws {
            if let ad = (adType.adType as? AdType<InterstitialAdManager>) {
                return ad.innerType
            }
            if let ad = (adType.adType as? AdType<RewardedAdManager>) {
                return ad.innerType
            }
            if let ad = (adType.adType as? AdType<ThumbnailAdManager>) {
                return ad.innerType
            }
            if let ad = (adType.adType as? AdType<BannerAdManager>) {
                return ad.innerType
            }
            throw EncodingError.invalidValue(adType, EncodingError.Context(codingPath: [], debugDescription: "Wrong adType"))
        }
    }
    
    internal var sortPosition: Int {
        (try? innerAdType) ?? 0
    }
    
    var displayIcon: Image? {
        if let ad = (adType.adType as? AdType<InterstitialAdManager>) {
            return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
        }
        if let ad = (adType.adType as? AdType<RewardedAdManager>) {
            return Image(systemName: "iphone.gen3.badge.play")
        }
        if let ad = (adType.adType as? AdType<ThumbnailAdManager>) {
            return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
        }
        if let ad = (adType.adType as? AdType<BannerAdManager>) {
            return Image(systemName: "platter.filled.bottom.iphone")
        }
        return nil
    }
    
    var tags: [OguryAdTag] {
        if let ad = (adType.adType as? AdType<InterstitialAdManager>) {
            return ad.tags
        }
        if let ad = (adType.adType as? AdType<RewardedAdManager>) {
            return ad.tags
        }
        if let ad = (adType.adType as? AdType<ThumbnailAdManager>) {
            return ad.tags
        }
        if let ad = (adType.adType as? AdType<BannerAdManager>) {
            return ad.tags
        }
        return []
    }
}

extension AdFormat: Codable {
    enum CodingKeys: String, CodingKey {
        case id, adType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let rawAdType: Int = try container.decode(Int.self, forKey: .adType)
       if let adType = try? AdType<InterstitialAdManager>.adType(from: rawAdType, adMarkUpRetriever: nil) {
            self.adType = AnyAdType(adType)
        } else if let adType = try? AdType<RewardedAdManager>.adType(from: rawAdType, adMarkUpRetriever: nil) {
            self.adType = AnyAdType(adType)
        } else if let adType = try? AdType<BannerAdManager>.adType(from: rawAdType, adMarkUpRetriever: nil) {
            self.adType = AnyAdType(adType)
        } else if let adType = try? AdType<ThumbnailAdManager>.adType(from: rawAdType, adMarkUpRetriever: nil) {
            self.adType = AnyAdType(adType)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "\(rawAdType) is not a proper adType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(innerAdType, forKey: .adType)
    }
}

struct AddFormatSection: Equatable, Identifiable, Hashable {
    let id = UUID()
    let title: String
    var adFormats: IdentifiedArrayOf<AdFormat> = []
}

struct AddFeature: Reducer {
    struct State: Equatable {
        static func == (lhs: AddFeature.State, rhs: AddFeature.State) -> Bool {
            lhs.sections == rhs.sections
        }
        
        var sections: IdentifiedArrayOf<AddFormatSection> = []
        let maxHeaderBidable: MaxHeaderBidable
        let dtFairBidHeaderBidable: DTFairBidHeaderBidable
        let unityLevelPlayBidable: UnityLevelPlayBidable
        
        init(maxHeaderBidable: MaxHeaderBidable, dtFairBidHeaderBidable: DTFairBidHeaderBidable, unityLevelPlayBidable: UnityLevelPlayBidable) {
            self.maxHeaderBidable = maxHeaderBidable
            self.dtFairBidHeaderBidable = dtFairBidHeaderBidable
            self.unityLevelPlayBidable = unityLevelPlayBidable
            let inter: AdType<InterstitialAdManager> = .interstitial
            let optIn: AdType<RewardedAdManager> = .rewarded
            let mpu: AdType<BannerAdManager> = .mpu
            let banner: AdType<BannerAdManager> = .banner
            let thumb: AdType<ThumbnailAdManager> = .thumbnail
            let interMax: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: maxHeaderBidable)
            let optInMax: AdType<RewardedAdManager> = .maxHeaderBidding(adType: .rewarded, adMarkUpRetriever: maxHeaderBidable)
            let mpuMax: AdType<BannerAdManager> = .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: maxHeaderBidable)
            let bannerMax: AdType<BannerAdManager> = .maxHeaderBidding(adType: .banner, adMarkUpRetriever: maxHeaderBidable)
            let interDTFairBid: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: dtFairBidHeaderBidable)
            let optInDTFairBid: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType: .rewarded, adMarkUpRetriever: dtFairBidHeaderBidable)
            let mpuDTFairBid: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: dtFairBidHeaderBidable)
            let bannerDTFairBid: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: dtFairBidHeaderBidable)
            let interUnityLevelPlay: AdType<InterstitialAdManager> = .unityLevelPlayHeaderBidding(adType: .interstitial, adMarkUpRetriever: unityLevelPlayBidable)
            let rewardedUnityLevelPlay: AdType<RewardedAdManager> = .unityLevelPlayHeaderBidding(adType: .rewarded, adMarkUpRetriever: unityLevelPlayBidable)
            let mpuUnityLevelPlay: AdType<BannerAdManager> = .unityLevelPlayHeaderBidding(adType: .mpu, adMarkUpRetriever: unityLevelPlayBidable)
            let bannerUnityLevelPlay: AdType<BannerAdManager> = .unityLevelPlayHeaderBidding(adType: .banner, adMarkUpRetriever: unityLevelPlayBidable)
            
            sections = [
                .init(title: "Ogury",
                      adFormats: [
                        .init(id: inter.uuid, adType: .init(inter)),
                        .init(id: optIn.uuid, adType: .init(optIn)),
                        .init(id: banner.uuid, adType: .init(banner)),
                        .init(id: mpu.uuid, adType: .init(mpu)),
                        .init(id: thumb.uuid, adType: .init(thumb))
                      ]),
                .init(title: "MAX Header Bidding",
                      adFormats: [
                        .init(id: interMax.uuid, adType: .init(interMax)),
                        .init(id: optInMax.uuid, adType: .init(optInMax)),
                        .init(id: bannerMax.uuid, adType: .init(bannerMax)),
                        .init(id: mpuMax.uuid, adType: .init(mpuMax))
                      ]),
                .init(title: "DT Fair Bid Header Bidding",
                      adFormats: [
                        .init(id: interDTFairBid.uuid, adType: .init(interDTFairBid)),
                        .init(id: optInDTFairBid.uuid, adType: .init(optInDTFairBid)),
                        .init(id: bannerDTFairBid.uuid, adType: .init(bannerDTFairBid)),
                        .init(id: mpuDTFairBid.uuid, adType: .init(mpuDTFairBid))
                      ]),
                .init(title: "Unity LevelPlay Header Bidding",
                      adFormats: [
                        .init(id: interUnityLevelPlay.uuid, adType: .init(interUnityLevelPlay)),
                        .init(id: rewardedUnityLevelPlay.uuid, adType: .init(rewardedUnityLevelPlay)),
                        .init(id: bannerUnityLevelPlay.uuid, adType: .init(bannerUnityLevelPlay)),
                        .init(id: mpuUnityLevelPlay.uuid, adType: .init(mpuUnityLevelPlay))
                      ])
            ]
        }
    }
    
    enum Action: Equatable  {
        case setSections(_: IdentifiedArrayOf<AddFormatSection>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case let .setSections(sections):
                    state.sections = sections
                    return .none
            }
        }
    }
}
