//
//  MaxAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 17/04/2025.
//

import Foundation
import SwiftUI
import AppLovinSDK
import AdsCardLibrary
import AdsCardAdapter

protocol MaxAdManager: AdManager {
    
}

enum MaxAdType: AdAdapterFormat, RawRepresentable, Equatable {
    case `default`(_: AdFormat)
    
    var adFormat: AdFormat {
        switch self {
            case let .default(adFormat): return adFormat
        }
    }
    
    var adUnit: String {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .interstitial: return "33ef6bc64f259a70"
                    case .rewardedVideo: return "bee4990ad3478ccd"
                    case .smallBanner: return "9bf5161c44fe5a8f"
                    case .mrec: return "79dbcc4ff65e3496"
                    default: fatalError("AdFormat \(adFormat) not supported")
                }
                
        }
    }
    
    var tags: [any AdTag] {
        [OguryAdTag.max, OguryAdTag.headerBidding]
    }
    
    var displayName: String {
        switch self {
            case let .default(adFormat): return adFormat.name
        }
    }
    
    var id: UUID { displayName.uuid }
    
    var sortOrder: Int {
        switch self {
            case let .default(adFormat):
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
            case 100: self = .`default`(.interstitial)
            case 101: self = .`default`(.rewardedVideo)
            case 102: self = .`default`(.smallBanner)
            case 103: self = .`default`(.mrec)
            default: return nil
        }
    }
    
    private static let maxPrefix = 100
    var rawValue: Int { MaxAdType.maxPrefix + self.sortOrder }
    
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    
    /// associated icon
    public var displayIcon: Image {
        switch self {
            case let .default(adFormat):
                switch adFormat {
                    case .interstitial: return Image(systemName: "iphone").symbolRenderingMode(.monochrome)
                    case .rewardedVideo: return Image(systemName: "iphone.gen3.badge.play")
                    case .smallBanner, .mrec: return Image(systemName: "platter.filled.bottom.iphone")
                    case .thumbnail: return Image(systemName: "rectangle.portrait.bottomright.inset.filled")
                    @unknown default: fatalError("unknown adFormat \(adFormat)")
                }
        }
    }
}
