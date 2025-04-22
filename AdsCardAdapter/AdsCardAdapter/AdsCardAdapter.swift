//
//  AdsCardAdapter.swift
//  AdsCardAdapter
//
//  Created by Jerome TONNELIER on 08/04/2025.
//
import UIKit
import SwiftUI
import AdsCardLibrary
import OguryCore.Private

/// The available ad format that the `AdsCardAdapter` can provide
public protocol AdAdapterFormat: Codable, Comparable, Equatable, Hashable, RawRepresentable, Identifiable where ID == UUID, RawValue == Int {
    /// the associated base adFormat (inter/rewarded/banner/thumb)
    var adFormat: AdFormat { get }
    /// the associated tags to display on the test app
    var tags: [any AdTag] { get }
    /// the name to display in the add panel
    var displayName: String { get }
    /// Identifiable
    var id: UUID { get }
    /// used for Comparable
    var sortOrder: Int { get }
    /// the icon to show on list
    var displayIcon: Image { get }
}

extension AdAdapterFormat {
    static func == (lhs: Self, rhs: Self) -> Bool {
        rhs.id == lhs.id
    }
}

extension AdAdapterFormat {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

public struct AdAdapterFormatSection: Identifiable, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: UUID = UUID()
    public var title: String
    public var formats: [any AdAdapterFormat]
    public init(title: String, formats: [any AdAdapterFormat]) {
        self.title = title
        self.formats = formats
    }
}

public struct AdapterOptions {
    public var showResetSdkButton: Bool = true
    public var showLogs: Bool = true
    public init(showResetSdkButton: Bool = true,
                showLogs: Bool = true) {
        self.showResetSdkButton = showResetSdkButton
        #if canImport(OguryAds)
        self.showLogs = showLogs
        #else
        self.showLogs = false
        #endif
    }
}

public protocol AdsCardAdaptable {
    var options: AdapterOptions { get }
    /// list of available `AdAdapterFormat` list to populate the Add panel of the test application
    var availableAdFormats: [AdAdapterFormatSection] { get }
    /// returns the various SDK used
    var sdkVersions: String { get }
    
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adAdapterFormat(fromRawValue rawValue: Int) throws(AdsCardAdapterError) -> any AdAdapterFormat
    /// starts the underlying SDK
    func startSdk() async
    /// resets the SDK if applicable
    func resetSdk()
    /// add a logger to OguryAds if available
    func add(logger: any OguryLogger)
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

extension Array where Element == any AdManager {
    func encode() -> [AdCardContainer] {
        map{ $0.encode() }
    }
}

public extension Decodable {
    static func loadJsonFromFile(bundle: Bundle,
                                 named fileName: String,
                                 extension extName: String? = nil) throws -> Self {
        guard let url = bundle.url(forResource: fileName, withExtension: extName),
              let json = try? Data(contentsOf: url) else {
            fatalError("No configuration file found")
        }
        let conf: Self = try JSONDecoder().decode(Self.self, from: json)
        return conf
    }
}
