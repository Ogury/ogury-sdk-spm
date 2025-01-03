//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary
import OguryAds
import UserDefault

enum ImportMethod: String, Codable, Equatable, CaseIterable, DefaultsValueConvertible {
    case file, rawText
    var displayText: String {
        switch self {
            case .file: return "Import file"
            case .rawText: return "Import json text"
        }
    }
    var shortDisplayText: String {
        switch self {
            case .file: return "File"
            case .rawText: return "Text"
        }
    }
}

struct SettingsContainer: Codable, Equatable {
    static let currentOs = "iOS"
    static let untitledAdSet = "Untitled Ad Set"
    private var settings = SettingsController()
    var enableAdUnitEditing: Bool {
        get { settings.enableAdUnitEditing }
        set { settings.enableAdUnitEditing = newValue }
    }
    var showCampaignId: Bool {
        get { settings.showCampaignId }
        set { settings.showCampaignId = newValue }
    }
    var showCreativeId: Bool {
        get { settings.showCreativeId }
        set { settings.showCreativeId = newValue }
    }
    var showSpecificOptions: Bool {
        get { settings.showSpecificOptions }
        set { settings.showSpecificOptions = newValue }
    }
    var showDspFields: Bool {
        get { settings.showDspFields }
        set { settings.showDspFields = newValue }
    }
    var bulkModeEnabled: Bool {
        get { settings.bulkModeEnabled }
        set { settings.bulkModeEnabled = newValue }
    }
    var startSDKWithApplication: Bool {
        get { settings.startSDKWithApplication }
        set { settings.startSDKWithApplication = newValue }
    }
    var numberOfSdkStart: Int {
        get { settings.numberOfSdkStart }
        set { settings.numberOfSdkStart = newValue }
    }
    var showTestMode: Bool {
        get { settings.showTestMode }
        set { settings.showTestMode = newValue }
    }
    var enableFeedbacks: Bool {
        get { settings.enableFeedbacks }
        set { settings.enableFeedbacks = newValue }
    }
    var usOptout: Bool {
        get { settings.usOptout }
        set { settings.usOptout = newValue }
    }
    var usOptoutPartner: Bool {
        get { settings.usOptoutPartner }
        set { settings.usOptoutPartner = newValue }
    }
    var importMethod: ImportMethod {
        get { settings.importMethod }
        set { settings.importMethod = newValue }
    }
    var name = SettingsContainer.untitledAdSet
    var os = SettingsContainer.currentOs
    var shouldUpdateAdUnits: Bool { os != SettingsContainer.currentOs }
    var logSettings: LogSettings!
    
    enum CodingKeys: CodingKey {
        case showCreativeId
        case showSpecificOptions
        case showDspFields
        case showCampaignId
        case bulkModeEnabled
        case showTestMode
        case name
        case os
        case enableAdUnitEditing
        case startSDKWithApplication
        case numberOfSdkStart
        case logSettings
        case importMethod
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showCreativeId = try container.decode(Bool.self, forKey: .showCreativeId)
        showSpecificOptions = try container.decode(Bool.self, forKey: .showSpecificOptions)
        showDspFields = try container.decode(Bool.self, forKey: .showDspFields)
        showCampaignId = try container.decode(Bool.self, forKey: .showCampaignId)
        bulkModeEnabled = try container.decode(Bool.self, forKey: .bulkModeEnabled)
        showTestMode = try container.decode(Bool.self, forKey: .showTestMode)
        name = try container.decode(String.self, forKey: .name)
        os = try container.decode(String.self, forKey: .os)
        startSDKWithApplication = try container.decodeIfPresent(Bool.self, forKey: .startSDKWithApplication) ?? false
        numberOfSdkStart = try container.decodeIfPresent(Int.self, forKey: .numberOfSdkStart) ?? 0
        enableAdUnitEditing = try container.decodeIfPresent(Bool.self, forKey: .enableAdUnitEditing) ?? true
        importMethod = try container.decodeIfPresent(ImportMethod.self, forKey: .importMethod) ?? .file
        logSettings = (try? container.decodeIfPresent(LogSettings.self, forKey: .logSettings)) ?? LogSettings()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(showCreativeId, forKey: .showCreativeId)
        try container.encode(showSpecificOptions, forKey: .showSpecificOptions)
        try container.encode(showDspFields, forKey: .showDspFields)
        try container.encode(showCampaignId, forKey: .showCampaignId)
        try container.encode(bulkModeEnabled, forKey: .bulkModeEnabled)
        try container.encode(showTestMode, forKey: .showTestMode)
        try container.encode(name, forKey: .name)
        try container.encode(os, forKey: .os)
        try container.encode(enableAdUnitEditing, forKey: .enableAdUnitEditing)
        try container.encode(numberOfSdkStart, forKey: .numberOfSdkStart)
        try container.encode(startSDKWithApplication, forKey: .startSDKWithApplication)
        try container.encode(logSettings, forKey: .logSettings)
        try container.encode(importMethod, forKey: .importMethod)
    }
    
    init(name: String = SettingsContainer.untitledAdSet) {
        self.name = name
        self.logSettings = LogSettings()
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.showCreativeId == rhs.showCreativeId &&
        lhs.showSpecificOptions == rhs.showSpecificOptions &&
        lhs.showDspFields == rhs.showDspFields &&
        lhs.showCampaignId == rhs.showCampaignId &&
        lhs.bulkModeEnabled == rhs.bulkModeEnabled &&
        lhs.startSDKWithApplication == rhs.startSDKWithApplication &&
        lhs.showTestMode == rhs.showTestMode &&
        lhs.enableAdUnitEditing == rhs.enableAdUnitEditing &&
        lhs.startSDKWithApplication == rhs.startSDKWithApplication &&
        lhs.numberOfSdkStart == rhs.numberOfSdkStart &&
        lhs.importMethod == rhs.importMethod &&
        lhs.name == rhs.name
    }
}

struct LogSettings: Codable {
    let allowedTypes: [OguryLogType] // TestAppAllowedLogTypes
    let allowedDisplay: OguryLogDisplay
    
    enum CodingKeys: CodingKey { case allowedTypes, allowedDisplay }
    
    init() {
        if let store = UserDefaults.standard.value(forKey: "OguryLogDisplay") as? UInt {
            allowedDisplay = OguryLogDisplay(rawValue: store)
        } else {
            allowedDisplay = [.SDK, .level, .origin, .tags]
        }
        if let types = UserDefaults.standard.value(forKey: "TestAppAllowedLogTypes") as? [OguryLogType] {
            allowedTypes = types
        } else {
            allowedTypes = [.internal, .publisher, .delegate]
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let types = try container.decodeIfPresent([String].self, forKey: .allowedTypes) {
            allowedTypes = types.compactMap{ OguryLogType($0) }
        } else {
            allowedTypes = [.internal, .publisher, .delegate]
        }
        TestAppLogController.shared.logger.allowedLogTypes = allowedTypes
        
        if let raw = try? container.decodeIfPresent(UInt.self, forKey: .allowedDisplay) {
            allowedDisplay = OguryLogDisplay(rawValue: raw)
        } else {
            allowedDisplay = [.SDK, .level, .origin, .tags]
        }
        TestAppLogController.shared.logger.logFormatter.displayOptions = allowedDisplay
        
        UserDefaults.standard.set(allowedDisplay.rawValue, forKey: "OguryLogDisplay")
        UserDefaults.standard.set(allowedTypes, forKey: "TestAppAllowedLogTypes")
        UserDefaults.standard.synchronize()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(allowedTypes.compactMap{ $0.rawValue }, forKey: .allowedTypes)
        try container.encode(allowedDisplay.rawValue, forKey: .allowedDisplay)
    }
}

struct AdsStorableContainer: Codable {
    let settings: SettingsContainer
    let cards: [[AdContainer]]
    private static let userDefaultKey = "AdsStorableContainer"
    fileprivate static let cardManager = AdsCardManager()
    fileprivate static var adDelegate: AdLifeCycleDelegate?
    var shouldUpdateAdUnits: Bool { settings.shouldUpdateAdUnits }
    
    init(settings: SettingsContainer = .init(),
         cards: [AdFormat: [any AdManager]]) {
        self.settings = settings
        self.cards = cards.compactMap { (adFormat, managers) in
            AdContainer.from(adFormat: adFormat, managers: managers)
        }
    }
    
    func json() -> String {
        guard let data = try? JSONEncoder().encode(self) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.setValue(data, forKey: AdsStorableContainer.userDefaultKey)
        UserDefaults.standard.synchronize()
    }
    
    enum ImportError: Error {
        case noFileAtURL
        case cantReadFile
    }
    static func load(from url: URL) throws -> AdsStorableContainer {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.noFileAtURL
        }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { throw ImportError.noFileAtURL }
        return try AdsStorableContainer.load(from: data)
    }
    
    static func load(from data: Data) throws -> AdsStorableContainer {
        guard let container: AdsStorableContainer = try? JSONDecoder().decode(self, from: data) else { throw ImportError.cantReadFile }
        return container
    }
    
    static func loadSavedData() throws -> AdsStorableContainer {
        guard let data = UserDefaults.standard.value(forKey: AdsStorableContainer.userDefaultKey) as? Data else { throw ImportError.noFileAtURL }
        guard let container: AdsStorableContainer = try? JSONDecoder().decode(self, from: data) else { throw ImportError.cantReadFile }
        return container
    }
    
    func retrieveAds(cardManager: AdsCardManager,
                     maxHeaderBidable: MaxBidder,
                     dtFairBidHeaderBidable: DTFairBidBidder,
                     unityLevelPlayBidable: UnityLevelPlayBidder,
                     viewController: UIViewController? = nil,
                     view: UIView? = nil,
                     adDelegate: AdLifeCycleDelegate? = nil) -> [AdFormat: [any AdManager]] {
        var adFormats: [AdFormat: [any AdManager]] = [:]
        cards.forEach { adContainers in
            if let adTuple = adContainers.convertToAdFormat(cardManager: cardManager,
                                                            maxHeaderBidable: maxHeaderBidable,
                                                            dtFairBidHeaderBidable: dtFairBidHeaderBidable,
                                                            unityLevelPlayBidable: unityLevelPlayBidable,
                                                            settings: settings,
                                                            viewController: viewController,
                                                            view: view,
                                                            adDelegate: adDelegate) {
                adFormats[adTuple.adFormat] = adTuple.managers
            }
        }
        return adFormats
    }
    
    //MARK: Codable
    enum CodingKeys: String, CodingKey {
        case settings, cards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decode(SettingsContainer.self, forKey: .settings)
        cards = try container.decode([[AdContainer]].self, forKey: .cards)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settings, forKey: .settings)
        let adContainers: [[AdContainer]] = cards
        try container.encode(adContainers, forKey: .cards)
    }
}

struct AdContainer: Codable {
    struct AdInformationsContainer: Codable {
        let adUnitId: String
        let campaignId: String?
        let creativeId: String?
        let settings: CardSettings
    }
    struct ThumbnailOptionsContainer: Codable {
        let thumbnailPosition: Int
        let thumbnailX: Int
        let thumbnailY: Int
        let thumbnailWidth: Int
        let thumbnailHeight: Int
    }
    struct CardSettings: Codable {
        let oguryTestModeEnabled: Bool
        let rtbTestModeEnabled: Bool
        let qaLabel: String
    }
    let name: String
    let adType: Int
    let adInformations: AdInformationsContainer
    let thumbnailOptions: ThumbnailOptionsContainer?
    
    fileprivate static func from(adFormat: AdFormat, managers: [any AdManager]) -> [Self] {
        managers
            .compactMap { manager in
                guard let adType = try? adFormat.innerAdType else {
                    fatalError("Unkown inner ad type \(adFormat.adType)")
                }
                let thumbnailOptions = (manager.options as? ThumbnailAdManagerOptions)?.thumbnailOptions
                return AdContainer.init(name: manager.options.baseOptions.adDisplayName,
                                        adType: adType,
                                        adInformations: .init(adUnitId: manager.options.baseOptions.adUnitId,
                                                              campaignId: manager.options.baseOptions.campaignId,
                                                              creativeId: manager.options.baseOptions.creativeId,
                                                              settings: .init(oguryTestModeEnabled: manager.options.baseOptions.oguryTestModeEnabled,
                                                                              rtbTestModeEnabled: manager.options.baseOptions.rtbTestModeEnabled,
                                                                              qaLabel: manager.options.baseOptions.qaLabel)),
                                        thumbnailOptions: thumbnailOptions == nil
                                        ? nil
                                        : .init(thumbnailPosition: thumbnailOptions!.rawCorner,
                                                thumbnailX: thumbnailOptions!.x,
                                                thumbnailY: thumbnailOptions!.y,
                                                thumbnailWidth: thumbnailOptions!.width,
                                                thumbnailHeight: thumbnailOptions!.height))
            }
    }
    
    fileprivate var adFormat: AdFormat {
        get throws {
            switch adType {
                case RawInnerAdType.interstitial.rawValue:
                    let adType: AdType<InterstitialAdManager> = .interstitial
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    let adType: AdType<InterstitialAdManager> = .maxHeaderBidding(adType: .interstitial, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    let adType: AdType<InterstitialAdManager> = .dtFairBidHeaderBidding(adType: .interstitial, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    let adType: AdType<InterstitialAdManager> = .unityLevelPlayHeaderBidding(adType: .interstitial, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                    
                case RawInnerAdType.rewarded.rawValue:
                    let adType: AdType<RewardedAdManager> = .rewarded
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    let adType: AdType<RewardedAdManager> = .maxHeaderBidding(adType: .rewarded, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    let adType: AdType<RewardedAdManager> = .dtFairBidHeaderBidding(adType: .rewarded, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    let adType: AdType<RewardedAdManager> = .unityLevelPlayHeaderBidding(adType: .rewarded, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                    
                case RawInnerAdType.thumbnail.rawValue:
                    let adType: AdType<ThumbnailAdManager> = .thumbnail
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                    
                case RawInnerAdType.mpu.rawValue:
                    let adType: AdType<BannerAdManager> = .mpu
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.mpu.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    let adType: AdType<BannerAdManager> = .maxHeaderBidding(adType: .mpu, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.mpu.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    let adType: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .mpu, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.mpu.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    let adType: AdType<BannerAdManager> = .unityLevelPlayHeaderBidding(adType: .mpu, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                
                case RawInnerAdType.banner.rawValue:
                    let adType: AdType<BannerAdManager> = .banner
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.banner.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    let adType: AdType<BannerAdManager> = .maxHeaderBidding(adType: .banner, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.banner.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    let adType: AdType<BannerAdManager> = .dtFairBidHeaderBidding(adType: .banner, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                case RawInnerAdType.banner.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    let adType: AdType<BannerAdManager> = .unityLevelPlayHeaderBidding(adType: .banner, adMarkUpRetriever: nil)
                    return AdFormat(id: adType.uuid, adType: .init(adType))
                    
                default: throw EncodingError.invalidValue(adType, .init(codingPath: [], debugDescription: "The adFormat is not allowed"))
            }
        }
    }
    
    fileprivate func adOptions<T: AdManager>(adType: AdType<T>, settings: SettingsContainer, viewController: UIViewController) -> AdManagerOptions {
        AdManagerOptions(showCampaignId: settings.showCampaignId,
                         showCreativeId: settings.showCreativeId,
                         showDspFields: settings.showDspFields,
                         showSpecificOptions: settings.showSpecificOptions,
                         viewController: viewController,
                         adDisplayName: name,
                         adUnitId: settings.shouldUpdateAdUnits
                         ? adType.defaultAdUnit(testMode: adInformations.adUnitId.isTestModeOn)
                         : adInformations.adUnitId,
                         campaignId: adInformations.campaignId,
                         creativeId: adInformations.creativeId,
                         adMarkUp: nil,
                         isSelected: false,
                         bulkModeEnabled: settings.bulkModeEnabled,
                         oguryTestModeEnabled: adInformations.settings.oguryTestModeEnabled,
                         rtbTestModeEnabled: adInformations.settings.rtbTestModeEnabled,
                         qaLabel: adInformations.settings.qaLabel)
    }
    fileprivate func bannerOptions<T: AdManager>(adType: AdType<T>, settings: SettingsContainer, view: UIView) -> BannerAdManagerOptions {
        BannerAdManagerOptions(showCampaignId: settings.showCampaignId,
                               showCreativeId: settings.showCreativeId,
                               showDspFields: settings.showDspFields,
                               showSpecificOptions: settings.showSpecificOptions,
                               view: view,
                               adDisplayName: name,
                               adUnitId: settings.shouldUpdateAdUnits
                               ? adType.defaultAdUnit(testMode: adInformations.adUnitId.isTestModeOn)
                               : adInformations.adUnitId,
                               campaignId: adInformations.campaignId,
                               creativeId: adInformations.creativeId,
                               adMarkUp: nil,
                               isSelected: false,
                               bulkModeEnabled: settings.bulkModeEnabled,
                               oguryTestModeEnabled: adInformations.settings.oguryTestModeEnabled,
                               rtbTestModeEnabled: adInformations.settings.rtbTestModeEnabled,
                               qaLabel: adInformations.settings.qaLabel)
    }
    fileprivate func thumbnailOptions<T: AdManager>(adType: AdType<T>, settings: SettingsContainer, viewController: UIViewController) -> ThumbnailAdManagerOptions {
        let corner: OguryRectCorner? = thumbnailOptions?.thumbnailPosition != nil
        ? OguryRectCorner(rawValue: thumbnailOptions!.thumbnailPosition)
        : nil
        let options = ThumbnailOptions(position: corner == nil ? CGPoint(x: CGFloat(thumbnailOptions?.thumbnailX ?? 0),
                                                                         y: CGFloat(thumbnailOptions?.thumbnailY ?? 0)) : nil,
                                       size: CGSize(width: CGFloat(thumbnailOptions?.thumbnailWidth ?? 180),
                                                    height: CGFloat(thumbnailOptions?.thumbnailHeight ?? 180)),
                                       offset: corner != nil ? OguryOffset(x: CGFloat(thumbnailOptions?.thumbnailX ?? 0),
                                                                           y: CGFloat(thumbnailOptions?.thumbnailY ?? 0)) : nil,
                                       corner: corner)
        
        return ThumbnailAdManagerOptions(showCampaignId: settings.showCampaignId,
                                         showCreativeId: settings.showCreativeId,
                                         showDspFields: settings.showDspFields,
                                         showSpecificOptions: settings.showSpecificOptions,
                                         viewController: viewController,
                                         thumbnailOptions: options,
                                         adDisplayName: name,
                                         adUnitId: settings.shouldUpdateAdUnits
                                         ? adType.defaultAdUnit(testMode: adInformations.adUnitId.isTestModeOn)
                                         : adInformations.adUnitId,
                                         campaignId: adInformations.campaignId,
                                         creativeId: adInformations.creativeId,
                                         adMarkUp: nil,
                                         isSelected: false,
                                         bulkModeEnabled: settings.bulkModeEnabled,
                                         oguryTestModeEnabled: adInformations.settings.oguryTestModeEnabled,
                                         rtbTestModeEnabled: adInformations.settings.rtbTestModeEnabled,
                                         qaLabel: adInformations.settings.qaLabel)
    }
}

extension Array where Element == AdContainer {
    func convertToAdFormat(cardManager: AdsCardManager,
                           maxHeaderBidable: MaxBidder,
                           dtFairBidHeaderBidable: DTFairBidBidder,
                           unityLevelPlayBidable: UnityLevelPlayBidder,
                           settings: SettingsContainer,
                           viewController: UIViewController?,
                           view: UIView?,
                           adDelegate: AdLifeCycleDelegate? = nil) -> (adFormat: AdFormat, managers: [any AdManager])? {
        guard !isEmpty, let adFormat = try? first?.adFormat else { return nil }
        return (adFormat: adFormat, managers: compactMap({ adContainer in
            switch adContainer.adType {
                case RawInnerAdType.interstitial.rawValue,
                    RawInnerAdType.interstitial.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    if let adType: AdType<InterstitialAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                      adMarkUpRetriever: maxHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType, 
                                                                  settings: settings,
                                                                  viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    if let adType: AdType<InterstitialAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                      adMarkUpRetriever: dtFairBidHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType,
                                                                  settings: settings,
                                                                  viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    if let adType: AdType<InterstitialAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                      adMarkUpRetriever: unityLevelPlayBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType,
                                                                  settings: settings,
                                                                  viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.rewarded.rawValue,
                    RawInnerAdType.rewarded.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    if let adType: AdType<RewardedAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                               adMarkUpRetriever: maxHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType,
                                                                  settings: settings,
                                                                  viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    if let adType: AdType<RewardedAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                               adMarkUpRetriever: dtFairBidHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType,
                                                                  settings: settings,
                                                                  viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    if let adType: AdType<RewardedAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                               adMarkUpRetriever: unityLevelPlayBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType,
                                                                  settings: settings,
                                                                  viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.thumbnail.rawValue:
                    if let adType: AdType<ThumbnailAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                   adMarkUpRetriever: nil),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.thumbnailOptions(adType: adType,
                                                                         settings: settings,
                                                                         viewController: viewController ?? UIViewController()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.banner.rawValue,
                    RawInnerAdType.mpu.rawValue:
                    if let adType: AdType<BannerAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                adMarkUpRetriever: nil),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.bannerOptions(adType: adType,
                                                                      settings: settings,
                                                                      view: view ?? UIView()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.banner.rawValue + RawInnerAdType.maxSuffix.rawValue,
                    RawInnerAdType.mpu.rawValue + RawInnerAdType.maxSuffix.rawValue:
                    if let adType: AdType<BannerAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                adMarkUpRetriever: maxHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.bannerOptions(adType: adType,
                                                                      settings: settings,
                                                                      view: view ?? UIView()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                
                case RawInnerAdType.banner.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue,
                    RawInnerAdType.mpu.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    if let adType: AdType<BannerAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                adMarkUpRetriever: unityLevelPlayBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.bannerOptions(adType: adType,
                                                                      settings: settings,
                                                                      view: view ?? UIView()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.mpu.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue,
                    RawInnerAdType.banner.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    if let adType: AdType<BannerAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                adMarkUpRetriever: dtFairBidHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.bannerOptions(adType: adType,
                                                                      settings: settings,
                                                                      view: view ?? UIView()),
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    return nil
                    
                    
                default: return nil
            }
            return nil
        }))
    }
}

extension AdType {
    func defaultAdUnit(options: MediationOptions? = nil, testMode: Bool) -> String {
        let currentOptions = options == nil ? Configuration.shared.options : options!
        switch self {
            case .interstitial: return currentOptions.interstitial.adUnitId + (testMode ? AdsCardManager.testModeSuffix : "")
            case .rewarded: return currentOptions.optIn.adUnitId + (testMode ? AdsCardManager.testModeSuffix : "")
            case .thumbnail: return (currentOptions.thumbnail?.adUnitId ?? "") + (testMode ? AdsCardManager.testModeSuffix : "")
            case .banner: return currentOptions.banner.adUnitId + (testMode ? AdsCardManager.testModeSuffix : "")
            case .mpu: return currentOptions.mpu.adUnitId + (testMode ? AdsCardManager.testModeSuffix : "")
            case .maxHeaderBidding(let adType, _): return adType.defaultAdUnit(options: Configuration.shared.maxOptions, testMode: testMode)
            case .dtFairBidHeaderBidding(let adType, _): return adType.defaultAdUnit(options: Configuration.shared.dtFairBidOptions, testMode: testMode)
            case .unityLevelPlayHeaderBidding(let adType, _): return adType.defaultAdUnit(options: Configuration.shared.unityLevelPlayOptions, testMode: testMode)
            @unknown default: fatalError()
        }
    }
}
