//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary
import OguryAds
import UserDefault
import AdsCardLibrary

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

struct AppPermissions: Codable, DefaultsValueConvertible {
    let settings: Bool
    let logs: Bool
    let add: Bool
    let export: Bool
    let bulkMode: Bool
    let devFeatures: Bool
    static let userDefaultKey = "AppPermissions"
    
    enum CodingKeys: String, CodingKey { case settings, logs, add, export, bulkMode, devFeatures }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decodeIfPresent(Bool.self, forKey: .settings) ?? true
        logs = try container.decodeIfPresent(Bool.self, forKey: .logs) ?? true
        add = try container.decodeIfPresent(Bool.self, forKey: .add) ?? true
        export = try container.decodeIfPresent(Bool.self, forKey: .export) ?? true
        bulkMode = try container.decodeIfPresent(Bool.self, forKey: .bulkMode) ?? true
        devFeatures = try container.decodeIfPresent(Bool.self, forKey: .devFeatures) ?? true
    }
    
    init() {
        settings = true
        logs = true
        add = true
        export = true
        bulkMode = true
        devFeatures = true
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
    var killWebviewMode: KillWebviewMode {
        get { settings.killWebviewMode }
        set { settings.killWebviewMode = newValue }
    }
    var consentManager: ConsentManager {
        get { settings.consentManager }
        set { settings.consentManager = newValue }
    }
    var name = SettingsContainer.untitledAdSet
    var os = SettingsContainer.currentOs
    var shouldUpdateAdUnits: Bool { os != SettingsContainer.currentOs }
    var logSettings: LogSettings!
    var permissions: AppPermissions {
        get { settings.appPermissions }
        set { settings.appPermissions = newValue }
    }
    
    enum CodingKeys: CodingKey {
        case showCreativeId,
             showDspFields,
             showCampaignId,
             bulkModeEnabled,
             showTestMode,
             name,
             os,
             enableAdUnitEditing,
             startSDKWithApplication,
             numberOfSdkStart,
             logSettings,
             importMethod,
             killWebviewMode,
             permissions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showCreativeId = try container.decodeIfPresent(Bool.self, forKey: .showCreativeId) ?? true
        showDspFields = try container.decodeIfPresent(Bool.self, forKey: .showDspFields) ?? false
        showCampaignId = try container.decodeIfPresent(Bool.self, forKey: .showCampaignId) ?? true
        bulkModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .bulkModeEnabled) ?? true
        showTestMode = try container.decodeIfPresent(Bool.self, forKey: .showTestMode) ?? true
        killWebviewMode = try container.decodeIfPresent(KillWebviewMode.self, forKey: .killWebviewMode) ?? .none
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? SettingsContainer.untitledAdSet
        os = try container.decodeIfPresent(String.self, forKey: .os) ?? SettingsContainer.currentOs
        startSDKWithApplication = try container.decodeIfPresent(Bool.self, forKey: .startSDKWithApplication) ?? false
        numberOfSdkStart = try container.decodeIfPresent(Int.self, forKey: .numberOfSdkStart) ?? 0
        enableAdUnitEditing = try container.decodeIfPresent(Bool.self, forKey: .enableAdUnitEditing) ?? true
        importMethod = try container.decodeIfPresent(ImportMethod.self, forKey: .importMethod) ?? .file
        logSettings = (try? container.decodeIfPresent(LogSettings.self, forKey: .logSettings)) ?? LogSettings()
        permissions = (try? container.decodeIfPresent(AppPermissions.self, forKey: .permissions)) ?? AppPermissions()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(showCreativeId, forKey: .showCreativeId)
        try container.encode(showDspFields, forKey: .showDspFields)
        try container.encode(showCampaignId, forKey: .showCampaignId)
        try container.encode(killWebviewMode, forKey: .killWebviewMode)
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
        lhs.showDspFields == rhs.showDspFields &&
        lhs.showCampaignId == rhs.showCampaignId &&
        lhs.bulkModeEnabled == rhs.bulkModeEnabled &&
        lhs.startSDKWithApplication == rhs.startSDKWithApplication &&
        lhs.showTestMode == rhs.showTestMode &&
        lhs.enableAdUnitEditing == rhs.enableAdUnitEditing &&
        lhs.startSDKWithApplication == rhs.startSDKWithApplication &&
        lhs.numberOfSdkStart == rhs.numberOfSdkStart &&
        lhs.importMethod == rhs.importMethod &&
        lhs.killWebviewMode == rhs.killWebviewMode &&
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
    fileprivate static var adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)?
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
                     adDelegate: AdLifeCycleDelegate? = nil) -> [AdFormat: [any OguryAdManager]] {
        var adFormats: [AdFormat: [any OguryAdManager]] = [:]
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
        let dspCreativeId: String?
        let dspRegion: DspRegion?
        let settings: CardSettings
    }
    struct CardSettings: Codable {
        let oguryTestModeEnabled: Bool
        let rtbTestModeEnabled: Bool
        let qaLabel: String
    }
    let name: String
    let adType: Int
    let adInformations: AdInformationsContainer
    
    fileprivate static func from(adFormat: AdFormat, managers: [any AdManager]) -> [Self] {
        managers
            .compactMap { manager in
                guard let adType = try? adFormat.innerAdType else {
                    fatalError("Unkown inner ad type \(adFormat.adType)")
                }
                return AdContainer.init(name: manager.options.baseOptions.adDisplayName,
                                        adType: adType,
                                        adInformations: .init(adUnitId: manager.adUnitId,
                                                              campaignId: manager.campaignId,
                                                              creativeId: manager.creativeId,
                                                              dspCreativeId: manager.dspCreativeId,
                                                              dspRegion: manager.dspRegion,
                                                              settings: .init(oguryTestModeEnabled: manager.cardConfiguration.oguryTestModeEnabled,
                                                                              rtbTestModeEnabled: manager.cardConfiguration.rtbTestModeEnabled,
                                                                              qaLabel: manager.cardConfiguration.qaLabel))
                )
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
    
    fileprivate func adOptions<T: OguryAdManager>(adType: AdType<T>, settings: SettingsContainer) -> AdManagerOptions {
        AdManagerOptions(showCampaignId: settings.showCampaignId,
                         showCreativeId: settings.showCreativeId,
                         showDspFields: settings.showDspFields,
                         adDisplayName: name,
                         adUnitId: settings.shouldUpdateAdUnits
                         ? adType.defaultAdUnit(testMode: adInformations.adUnitId.isTestModeOn)
                         : adInformations.adUnitId,
                         campaignId: adInformations.campaignId,
                         creativeId: adInformations.creativeId,
                         dspCreativeId: adInformations.dspCreativeId,
                         dspRegion: adInformations.dspRegion,
                         isSelected: false,
                         bulkModeEnabled: settings.bulkModeEnabled,
                         oguryTestModeEnabled: adInformations.settings.oguryTestModeEnabled,
                         rtbTestModeEnabled: adInformations.settings.rtbTestModeEnabled,
                         killWebviewMode: settings.killWebviewMode,
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
                           adDelegate: AdLifeCycleDelegate? = nil) -> (adFormat: AdFormat, managers: [any OguryAdManager])? {
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
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    if let adType: AdType<InterstitialAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                      adMarkUpRetriever: dtFairBidHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.interstitial.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    if let adType: AdType<InterstitialAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                      adMarkUpRetriever: unityLevelPlayBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
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
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.dtFairBidSuffix.rawValue:
                    if let adType: AdType<RewardedAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                  adMarkUpRetriever: dtFairBidHeaderBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.rewarded.rawValue + RawInnerAdType.unityLevelPlaySuffix.rawValue:
                    if let adType: AdType<RewardedAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                  adMarkUpRetriever: unityLevelPlayBidable),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
                                   adDelegate: adDelegate) {
                        return adManager
                    }
                    
                case RawInnerAdType.thumbnail.rawValue:
                    if let adType: AdType<ThumbnailAdManager> = try? AdType.adType(from: adContainer.adType,
                                                                                   adMarkUpRetriever: nil),
                       let adManager = try? AdsStorableContainer
                        .cardManager
                        .adManager(for: adType,
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
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
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
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
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
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
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
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
                                   options: adContainer.adOptions(adType: adType, settings: settings),
                                   viewController: viewController,
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
            case .interstitial: return currentOptions.interstitial.adUnitId + (testMode ? .testModeSuffix : "")
            case .rewarded: return currentOptions.optIn.adUnitId + (testMode ? .testModeSuffix : "")
            case .thumbnail: return (currentOptions.thumbnail?.adUnitId ?? "") + (testMode ? .testModeSuffix : "")
            case .banner: return currentOptions.banner.adUnitId + (testMode ? .testModeSuffix : "")
            case .mpu: return currentOptions.mpu.adUnitId + (testMode ? .testModeSuffix : "")
            case .maxHeaderBidding(let adType, _): return adType.defaultAdUnit(options: Configuration.shared.maxOptions, testMode: testMode)
            case .dtFairBidHeaderBidding(let adType, _): return adType.defaultAdUnit(options: Configuration.shared.dtFairBidOptions, testMode: testMode)
            case .unityLevelPlayHeaderBidding(let adType, _): return adType.defaultAdUnit(options: Configuration.shared.unityLevelPlayOptions, testMode: testMode)
            @unknown default: fatalError()
        }
    }
}
