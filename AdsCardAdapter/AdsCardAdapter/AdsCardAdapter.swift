//
//  AdsCardAdapter.swift
//  AdsCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//
import UIKit
import AdsCardLibrary

/// The available ad format that the `AdsCardAdapter` can provide
public protocol AdAdapterFormat: Codable, Identifiable where ID == UUID {
    /// the associated base adFormat (inter/rewarded/banner/thumb)
    var adFormat: AdFormat { get }
    /// the associated tags to display on the test app
    var tags: [any AdTag] { get set }
    /// the name to display in the add panel and ad list
    var displayName: String { get }
}

public struct AdAdapterFormatSection: Identifiable {
    public var id: UUID = UUID()
    public var title: String
    public var formats: [any AdAdapterFormat]
}

public protocol AdsCardAdaptable {
    /// list of available `AdAdapterFormat` list to populate the Add panel of the test application
    var availableAdFormats: [AdAdapterFormatSection] { get }
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager
    /// starts the underlying SDK
    func startSdk()
}

public enum AdsCardAdapterError: Error {
    case noSuitableAdapterAvailable
}

