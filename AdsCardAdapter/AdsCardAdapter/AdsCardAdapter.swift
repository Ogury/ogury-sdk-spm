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

public protocol AdsCardAdapterAction {
    var name: String { get }
    var icon: Image? { get }
    func perform()
}

public protocol AdsCardAdaptable {
    /// list of available `AdAdapterFormat` list to populate the Add panel of the test application
    var availableAdFormats: [AdAdapterFormatSection] { get }
    /// returns the various SDK used
    var sdkVersions: String { get }
    /// custom actions to add to the `more` test app menu
    var actions: [AdsCardAdapterAction] { get }
    /// populates the what's new sheet of the test app. Must be a markdown string
    var whatsNew: String? { get }
    
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adManager(for adFormat: any AdAdapterFormat,
                   options: AdViewOptions,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adManager(from container: AdCardContainer,
                   viewController: UIViewController?,
                   adDelegate: AdLifeCycleDelegate?) throws(AdsCardAdapterError) -> any AdManager
    /// returns the AdManager associated with an `AdAdapterFormat`
    /// - throws: throws an exception if no adapter is available
    func adAdapterFormat(fromRawValue rawValue: Int, fileVersion: FileVersion) throws(AdsCardAdapterError) -> any AdAdapterFormat
    /// starts the underlying SDK
    func startSdk() async
    /// resets the SDK if applicable
    func resetSdk()
    /// add a logger to OguryAds if available
    func add(logger: any OguryLogger)
    /// sets the log level if available
    func setLogLevel(_ level: OguryLogLevel)
    /// sets The allowed type of loggers if available
    func setAllowedTypes(_ types: [String])
}

extension AdsCardAdaptable {
    public func setAllowedTypes(_ types: [String]) {
        #if canImport(OguryCore)
            let obj = OGCInternal.shared()
            let sel = NSSelectorFromString("setAllowedTypes:")
            let meth = class_getInstanceMethod(object_getClass(obj), sel)
            let imp = method_getImplementation(meth!)
            typealias ClosureType = @convention(c) (AnyObject, Selector, Array<String>) -> Void
            let sayHiTo: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            sayHiTo(obj, sel, types)
        #endif
    }
    
    public var whatsNew: String? {
"""
**No information provided**

Please reach out to [askInApp](https://weareogury.slack.com/archives/C07Q1JP7P96)
"""
    }
}

public enum AdsCardAdapterError: Error {
    case noSuitableAdapterAvailable
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
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "File not found"))
        }
        let conf: Self = try JSONDecoder().decode(Self.self, from: json)
        return conf
    }
}
