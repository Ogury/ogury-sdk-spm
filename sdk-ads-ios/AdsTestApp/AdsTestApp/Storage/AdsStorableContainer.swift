//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary
import OguryAds
import UserDefault
import AdsCardLibrary
import AdsCardAdapter

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
    let cards: [[AdCardContainer]]
    private static let userDefaultKey = "AdsStorableContainer"
    fileprivate static let cardManager = AdsCardManager()
    fileprivate static var adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)?
    var shouldUpdateAdUnits: Bool { settings.shouldUpdateAdUnits }
    
    init(settings: SettingsContainer = .init(),
         cards: [AdCardList]) {
        self.settings = settings
        self.cards = cards.compactMap { cardList in
            cardList.adManagers.map{ $0.encode() }
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
    
    func retrieveAds(viewController: UIViewController? = nil,
                     adDelegate: AdLifeCycleDelegate? = nil) -> [AdCardList] {
        //TODO: 🍀
        var list: [AdCardList] = []
        cards.forEach { card in
            guard let adType = card.first?.adType,
                  let adFormat: any AdAdapterFormat = try? SdkLauncher.shared.adapter.adAdapterFormat(fromRawValue: adType) else { return }
            var adManagers: [any AdManager] = []
            card.forEach { container in
                if let manager = try? SdkLauncher.shared.adapter.adManager(for: adFormat,
                                                                           options: container.adAdapterOptions,
                                                                           viewController: viewController,
                                                                           adDelegate: adDelegate) {
                    adManagers.append(manager)
                }
            }
            guard !card.isEmpty else { return }
            list.append(.init(adAdapterFormat: adFormat, adManagers: adManagers))
        }
        return list
    }
    
    //MARK: Codable
    enum CodingKeys: String, CodingKey {
        case settings, cards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decode(SettingsContainer.self, forKey: .settings)
        cards = try container.decode([[AdCardContainer]].self, forKey: .cards)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settings, forKey: .settings)
        let adContainers: [[AdCardContainer]] = cards
        try container.encode(adContainers, forKey: .cards)
    }
}

extension AdCardContainer {
    var adAdapterOptions: AdViewOptions {
        .init(adParameters: .init(adUnitId: adInformations.adUnitId,
                                  campaignId: adInformations.campaignId,
                                  creativeId: adInformations.creativeId,
                                  dspCreativeId: adInformations.dspCreativeId,
                                  dspRegion: adInformations.dspRegion),
              cardConfiguration: .init(oguryTestModeEnabled: adInformations.settings.oguryTestModeEnabled,
                                       rtbTestModeEnabled: adInformations.settings.rtbTestModeEnabled,
                                       qaLabel: adInformations.settings.qaLabel))
    }
}
