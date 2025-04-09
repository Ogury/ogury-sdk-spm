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
    var tags: [any AdTag] { get }
    /// the name to display in the add panel and ad list
    var displayName: String { get }
}

public struct AdAdapterFormatSection: Identifiable {
    public var id: UUID = UUID()
    public var title: String
    public var formats: [any AdAdapterFormat]
    public init(title: String, formats: [any AdAdapterFormat]) {
        self.title = title
        self.formats = formats
    }
}

public protocol AdsCardAdaptable {
    var assetKey: String { get }
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

public extension String {
    var uuid: UUID {
        var hasher = Hasher()
        hasher.combine(self)
        let hash = hasher.finalize()
        // Convert hash (Int) into a UUID-compatible format
        var uuidBytes = [UInt8](repeating: 0, count: 16)
        withUnsafeBytes(of: hash.bigEndian) { hashBytes in
            for i in 0..<min(hashBytes.count, 16) {
                uuidBytes[i] = hashBytes[i]
            }
        }
        return UUID(uuid: (
            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
            uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
            uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
            uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
        ))
    }
}
