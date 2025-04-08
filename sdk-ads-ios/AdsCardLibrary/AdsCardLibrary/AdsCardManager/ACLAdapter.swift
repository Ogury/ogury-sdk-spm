//
//  AdsCardAdapter.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 04/04/2025.
//

import UIKit

/// The available ad format that the `AdsCardAdapter` can provide
public protocol ACLAdapterFormat: Codable, Identifiable where ID == UUID {
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

public struct AdAdapterFormatOptions: Codable {
    /// - returns: return `true` if rtbTestMode (i.e. add `test:0` to bidding request) can be used on the server side, `false` if not
    var enableRtbTestMode: Bool = false
}

public struct AdAdapterFormatSection: Identifiable {
    public var id: UUID = UUID()
    public var title: String
    public var formats: [any ACLAdapterFormat]
}

public protocol ACLAdapter {
    /// list of available `AdAdapterFormat` list to populate the Add panel of the test application
    var availableAdFormats: [AdAdapterFormatSection] { get }
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adManager(for adFormat: any ACLAdapterFormat,
                   options: AdManagerOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(ACLAdapterError) -> any AdManager
}

public enum ACLAdapterError: Error {
    case noSuitableAdapterAvailable
}
