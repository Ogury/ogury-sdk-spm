//
//  MaxAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 17/04/2025.
//

import Foundation
import AppLovinSDK
import AdsCardLibrary
import AdsCardAdapter

protocol MaxAdManager: AdManager {
    
}

enum AdType: AdAdapterFormat, RawRepresentable, Equatable {
    case max(_: AdFormat)
    
    var adFormat: AdFormat {
        switch self {
            case let .max(adFormat): return adFormat
        }
    }
    
    var tags: [any AdTag] {
        [OguryAdTag.max, OguryAdTag.headerBidding]
    }
    
    var displayName: String {
        switch self {
            case let .max(adFormat): return adFormat.name
        }
    }
    
    var id: UUID { displayName.uuid }
    
    var sortOrder: Int {
        switch self {
            case let .max(adFormat):
                switch adFormat {
                    case .interstitial: return 0
                    case .rewardedVideo: return 1
                    case .smallBanner: return 2
                    case .mrec: return 3
                    case .thumbnail: fatalError("No thumbnail on AppLovin")
                    @unknown default: fatalError("unknown adFormat \(adFormat)")
                }
        }
    }
    
    init?(rawValue: Int) {
        switch rawValue {
            case 100: self = .max(.interstitial)
            case 101: self = .max(.rewardedVideo)
            case 102: self = .max(.smallBanner)
            case 103: self = .max(.mrec)
            default: return nil
        }
    }
    
    private static let maxPrefix = 100
    var rawValue: Int { AdType.maxPrefix + self.sortOrder }
    
    static func < (lhs: AdType, rhs: AdType) -> Bool { lhs.rawValue < rhs.rawValue }
    
    /// associated icon
    public var displayIcon: Image {
        switch self {
            case let .max(adFormat):
                switch adFormat {
                    case .interstitial: return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
                    case .rewardedVideo: return Image(systemName: "iphone.gen3.badge.play")
                    case .smallBanner, .mrec: return Image(systemName: "platter.filled.bottom.iphone")
                    case .thumbnail: return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
                }
        }
    }
}
