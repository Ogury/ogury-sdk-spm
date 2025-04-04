//
//  AdsCardAdapter.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/04/2025.
//

import Foundation

/// The available ad format that the `AdsCardAdapter` can provide
public protocol AdAdapterFormat: Identifiable where ID == UUID {
    /// the associated base adFormat (inter/rewarded/banner/thumb)
    var adFormat: AdFormat { get }
    /// the associated tags to display on the test app
    var tags: [any AdTag] { get set }
    /// the name to display in the add panel and ad list
    var displayName: String { get }
    /// the inner value to decode/encode
    var adType: Int { get }
    /// specific options that comes with current format
    var options: AdAdapterFormatOptions { get set }
}

public protocol AdAdapterFormatOptions {
    /// - returns: return `true` if rtbTestMode (i.e. add `test:0` to bidding request) can be used on the server side, `false` if not
    var enableRtbTestMode: Bool { get set }
}

public protocol AdsCardAdapter {
    /// list of available `AdAdapterFormat` list to populate the Add panel of the test application
    var availableAdFormats: [[any AdAdapterFormat]] { get }
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adManager(for adFormat: any AdAdapterFormat) throws -> any AdManager
}
