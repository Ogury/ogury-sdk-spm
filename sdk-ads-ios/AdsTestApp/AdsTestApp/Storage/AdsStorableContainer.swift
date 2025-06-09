//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import AdsCardLibrary
import OguryCore.Private
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

struct SettingsPermissions: OptionSet, Codable {
    let rawValue: Int
    static let noCards = SettingsPermissions(rawValue: 1 << 0)
    static let showEditAdUnitToggle = SettingsPermissions(rawValue: 1 << 1)
    static let showCampaignToggle = SettingsPermissions(rawValue: 1 << 2)
    static let showCreativeToggle = SettingsPermissions(rawValue: 1 << 3)
    static let showDspToggle = SettingsPermissions(rawValue: 1 << 4)
    static let showAudioToggle = SettingsPermissions(rawValue: 1 << 5)
    static let showTestModeToggle = SettingsPermissions(rawValue: 1 << 6)
    static let showKillWebviewToggle = SettingsPermissions(rawValue: 1 << 7)
    static let showBulkModeToggle = SettingsPermissions(rawValue: 1 << 8)
    static let showResetProfigToggle = SettingsPermissions(rawValue: 1 << 9)
    static var allCases: SettingsPermissions = [
        .showEditAdUnitToggle,
        .showAudioToggle,
        .showBulkModeToggle,
        .showCampaignToggle,
        .showCreativeToggle,
        .showDspToggle,
        .showKillWebviewToggle,
        .showResetProfigToggle,
        .showTestModeToggle
    ]
}

struct AppPermissions: Codable, DefaultsValueConvertible {
    let settings: Bool
    let logs: Bool
    let add: Bool
    let export: Bool
    let bulkMode: Bool
    let devFeatures: Bool
    let settingPermissions: SettingsPermissions
    static let userDefaultKey = "AppPermissions"
    
    enum CodingKeys: String, CodingKey {
        case settings, logs, add, export, bulkMode, devFeatures, settingPermissions
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decodeIfPresent(Bool.self, forKey: .settings) ?? true
        logs = try container.decodeIfPresent(Bool.self, forKey: .logs) ?? true
        add = try container.decodeIfPresent(Bool.self, forKey: .add) ?? true
        export = try container.decodeIfPresent(Bool.self, forKey: .export) ?? true
        bulkMode = try container.decodeIfPresent(Bool.self, forKey: .bulkMode) ?? true
        devFeatures = try container.decodeIfPresent(Bool.self, forKey: .devFeatures) ?? true
        settingPermissions = try container.decodeIfPresent(SettingsPermissions.self, forKey: .settingPermissions) ?? .allCases
    }
    
    init() {
        settings = true
        logs = true
        add = true
        export = true
        bulkMode = true
        devFeatures = true
        settingPermissions = .allCases
    }
}

enum FileVersion: Int, Codable, Equatable {
    case preVersion = 0
    case one = 1
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
    var fileVersion: FileVersion = .one
    static var currentFileVersion: FileVersion = .one
    
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
        case settings, cards, fileVersion
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileVersion = (try? container.decodeIfPresent(FileVersion.self, forKey: .fileVersion)) ?? .preVersion
        
        var settingsClass = SettingsContainer.self
        var cardsClass = [[AdCardContainer]].self
        if fileVersion != AdsStorableContainer.currentFileVersion {
            settingsClass = SettingsContainer.self
            cardsClass = [[AdCardContainer]].self
        }
        settings = try container.decode(settingsClass, forKey: .settings)
        cards = try container.decode(cardsClass, forKey: .cards)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settings, forKey: .settings)
        let adContainers: [[AdCardContainer]] = cards
        try container.encode(adContainers, forKey: .cards)
        try container.encode(fileVersion, forKey: .fileVersion)
    }
}

extension AdCardContainer {
    var adAdapterOptions: AdViewOptions {
        let settings = SettingsController()
        return .init(adParameters: .init(adUnitId: adInformations.adUnitId,
                                         campaignId: adInformations.campaignId,
                                         creativeId: adInformations.creativeId,
                                         dspCreativeId: adInformations.dspCreativeId,
                                         dspRegion: adInformations.dspRegion),
                     cardConfiguration: .init(enableAdUnitEditing: settings.enableAdUnitEditing,
                                              showCampaignId: settings.showCampaignId,
                                              showCreativeId: settings.showCreativeId,
                                              showDspFields: settings.showDspFields,
                                              adDisplayName: name,
                                              bulkModeEnabled: settings.bulkModeEnabled,
                                              oguryTestModeEnabled: adInformations.settings.oguryTestModeEnabled,
                                              showTestModeButton: settings.showTestMode,
                                              rtbTestModeEnabled: adInformations.settings.rtbTestModeEnabled,
                                              killWebviewMode: settings.killWebviewMode,
                                              qaLabel: adInformations.settings.qaLabel))
    }
}

extension AdsStorableContainer: CustomStringConvertible {
    public var description: String {
"""
/*************************************/
/****** C O N F I G   F I L E ********/
/*************************************/

~~~> SETTINGS
\(settings)

~~~> CARDS 
\(cards)

/*************************************/
/****** E N D   O F   F I L E ********/
/*************************************/
"""
    }
}

extension OguryLogDisplay: @retroactive CustomStringConvertible {
    public var description: String {
        var str = ""
        if contains(.SDK) {
            str += "SDK"
        }
        if contains(.date) {
            str += str.isEmpty ? "Date" : " - Date"
        }
        if contains(.level) {
            str += str.isEmpty ? "Level" : " - Level"
        }
        if contains(.origin) {
            str += str.isEmpty ? "Origin" : " - Origin"
        }
        if contains(.tags) {
            str += str.isEmpty ? "Tags" : " - Tags"
        }
        if contains(.type) {
            str += str.isEmpty ? "Type" : " - Type"
        }
        return str
    }
}

extension LogSettings: CustomStringConvertible {
    public var description: String {
"""
Allowed type    : \(allowedTypes.reduce("", { "\($0.isEmpty ? $0 : "\($0) - ")" + "\($1.rawValue)" }))
Allowed Display : \(allowedDisplay)
"""
    }
}

extension AppPermissions: CustomStringConvertible {
    public var description: String {
"""
settings            : \(settings)
logs                : \(logs)
add                 : \(add)
export              : \(export)
bulkMode            : \(bulkMode)
devFeatures         : \(devFeatures)
settingPermissions  : \(settingPermissions)

"""
    }
}

extension SettingsPermissions: CustomStringConvertible {
    public var description: String {
        var str = ""
        if contains(.noCards) {
            str += str.isEmpty ? "noCards" : " - noCards"
        }
        if contains(.showEditAdUnitToggle) {
            str += str.isEmpty ? "showEditAdUnit" : " - showEditAdUnit"
        }
        if contains(.showCampaignToggle) {
            str += str.isEmpty ? "showCampaign" : " - showCampaign"
        }
        if contains(.showCreativeToggle) {
            str += str.isEmpty ? "showCreative" : " - showCreative"
        }
        if contains(.showDspToggle) {
            str += str.isEmpty ? "showDsp" : " - showDsp"
        }
        if contains(.showAudioToggle) {
            str += str.isEmpty ? "showAudio" : " - showAudio"
        }
        if contains(.showTestModeToggle) {
            str += str.isEmpty ? "showTestMode" : " - showTestMode"
        }
        if contains(.showKillWebviewToggle) {
            str += str.isEmpty ? "showKillWebview" : " - showKillWebview"
        }
        if contains(.showBulkModeToggle) {
            str += str.isEmpty ? "showBulkMode" : " - showBulkMode"
        }
        if contains(.showResetProfigToggle) {
            str += str.isEmpty ? "showResetProfig" : " - showResetProfig"
        }
        return str
    }
}

extension SettingsContainer: CustomStringConvertible {
    public var description: String {
"""
*** SHOW BEHAVIOR ***
enableAdUnitEditing         : \(enableAdUnitEditing)
showCampaignId              : \(showCampaignId)
showCreativeId              : \(showCreativeId)
showDspFields               : \(showDspFields)
bulkModeEnabled             : \(bulkModeEnabled)
startSDKWithApplication     : \(startSDKWithApplication)
numberOfSdkStart            : \(numberOfSdkStart)
showTestMode                : \(showTestMode)
enableFeedbacks             : \(enableFeedbacks)
usOptout                    : \(usOptout)
usOptoutPartner             : \(usOptoutPartner)
importMethod                : \(importMethod)
killWebviewMode             : \(killWebviewMode)
consentManager              : \(consentManager)
name                        : \(name)
os                          : \(os)

*** LOG SETTINGS ***
\(logSettings!)

*** PERMISSIONS ***
\(permissions)
"""
    }
}
