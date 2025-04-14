//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture
import AdsCardLibrary
import SwiftUI
import OguryAds
import OguryCore
import AdsCardAdapter
import AdsCardLibrary
import OMSDK_Ogury

struct AdCardList: Hashable, Equatable, Comparable, Identifiable {
    var id: Int { adAdapterFormat.hashValue }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.adAdapterFormat.hashValue == rhs.adAdapterFormat.hashValue
        && lhs.adManagers.hashValue == rhs.adManagers.hashValue
    }
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.adAdapterFormat.sortOrder < rhs.adAdapterFormat.sortOrder
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(adAdapterFormat)
        hasher.combine(adManagers.map{ $0.hashValue })
    }
    
    var adAdapterFormat: any AdAdapterFormat
    var adManagers: [any AdManager] = []
    init(adAdapterFormat: any AdAdapterFormat, adManagers: [any AdManager]) {
        self.adAdapterFormat = adAdapterFormat
        self.adManagers = adManagers
    }
    
    mutating func append(_ adManager: any AdManager) {
        adManagers.append(adManager)
    }
    mutating func remove(_ adManager: any AdManager) {
        adManagers.removeAll(where: { $0.id == adManager.id })
    }
}

public extension Array where Element == any AdManager {
    func hash(into hasher: inout Hasher) {
        for element in self {
            hasher.combine(element)
        }
    }
    var hashValue: Int {
        var hasher = Hasher()
        hash(into: &hasher)
        return hasher.finalize()
    }
}

struct About {
    var appName: String { Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Ads Test Application" }
    var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String }
    var appBuild: String { Bundle.main.infoDictionary?["CFBundleVersion"] as! String }
    var environment: String { Bundle.main.object(forInfoDictionaryKey: "DefaultEnv") as? String ?? "" }
    var bundleId: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "" }
    var omidVersion: String { OMIDOgurySDK.versionString() }
    var assetKey: String { SdkLauncher.assetKey }
    var coreSdkVersion: String { String(describing: OGCInternal.shared().getVersion()) }
    var ogurySdkVersion: String { "5.0.2" }
    var adsSdkVersion: String {
        let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
        return "\(String(describing: OGAInternal.shared().getVersion())) (\(origin == "Pod" ? "Release" : "Development"))"
    }
}

struct MainFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    var adHostingViewController: UIViewController!
    var adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)!
    let cardManager = AdsCardManager(logger: TestAppLogController.shared.logger)
    
    struct State: Equatable {
        static func == (lhs: MainFeature.State, rhs: MainFeature.State) -> Bool {
            var isEqual = lhs.adFormats == rhs.adFormats
            guard lhs.adFormats.count == rhs.adFormats.count,
                  lhs.showLogs == rhs.showLogs else { return false }
//            lhs.adFormats.forEach { (key, value) in
//                if !rhs.adFormats.keys.contains(key) {
//                    isEqual = false
//                    return
//                }
//                if value.count != rhs.adFormats[key]!.count {
//                    isEqual = false
//                    return
//                }
//                let leftFormats = lhs.adFormats.compactMap({ $0.value }).flatMap{ $0 }
//                let rightFormats = rhs.adFormats.compactMap({ $0.value }).flatMap{ $0 }
//                zip(leftFormats,
//                    rightFormats)
//                .forEach { lhsManager, rhsManager in
//                    if lhsManager.adConfiguration != rhsManager.adConfiguration
//                        || lhsManager.cardConfiguration != rhsManager.cardConfiguration {
//                        isEqual = false
//                        return
//                    }
//                }
//            }
            return isEqual && lhs.destination == rhs.destination && lhs.setName == rhs.setName
        }
        
        var adFormats: [AdCardList] = []
        @PresentationState var destination: Destination.State?
        @BindingState var setName = ""
        fileprivate var settingsPriorToChange: SettingsContainer = SettingsContainer()
        var showLogs = SettingsController().showLogsSheet
        
        mutating func removeCardFor(managerId: UUID) {
            adFormats = adFormats.map { card in
                var card = card
                card.adManagers = card.adManagers.filter({ $0.id == managerId })
                return card
            }
            storeCards()
        }
        
        func storeCards(settings: SettingsContainer? = nil) {
            let container = AdsStorableContainer(settings: settings ?? .init(), cards: adFormats)
            container.save()
        }
    }
    
    enum Action: BindableAction, Equatable  {
        static func == (lhs: MainFeature.Action, rhs: MainFeature.Action) -> Bool {
            switch (lhs, rhs) {
                case let (.destination(lhsValue), .destination(rhsValue)): return lhsValue == rhsValue
                case let (.binding(lhsValue), .binding(rhsValue)): return lhsValue == rhsValue
                case (.settingsButtonTapped, .settingsButtonTapped): return true
                case (.bulkModeButtonTapped, .bulkModeButtonTapped): return true
                case (.addButtonTapped, .addButtonTapped): return true
                case (.showConsentButtonTapped, .showConsentButtonTapped): return true
                case (.startSDKButtonTapped, .startSDKButtonTapped): return true
                case (.cancelAddButtonTapped, .cancelAddButtonTapped): return true
                case (.addFormatButtonTapped, .addFormatButtonTapped): return true
                case (.exportButtonTapped, .exportButtonTapped): return true
                case (.importButtonTapped, .importButtonTapped): return true
                case (.removeSetButtonTapped, .removeSetButtonTapped): return true
                case let (.deleteCard(lhsValue), .deleteCard(rhsValue)):
                    return lhsValue == rhsValue
                case (.saveCards, .saveCards): return true
                case (.refreshAllCards, .refreshAllCards): return true
                default:
                    return false
            }
        }
        
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case settingsButtonTapped
        case bulkModeButtonTapped
        case addButtonTapped
        case showConsentButtonTapped
        case startSDKButtonTapped
        case cancelAddButtonTapped
        case addFormatButtonTapped
        case exportButtonTapped
        case importButtonTapped
        case removeSetButtonTapped
        case deleteCard(id: UUID)
        case saveCards
        case refreshAllCards(_: [AdCardList])
        case showLogs(_: Bool)
        case importFile(_: URL)
        case loadFromContainer(_: AdsStorableContainer)
        case aboutButtonTapped
        
        enum Alert {
            case notImplemented
            case removeSet
            case cantImportFile
        }
    }
    
    enum CancelId: Hashable {
        case saveSettings
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.setName) { oldValue, newValue in
                Reduce { state, action in
                    return .send(.saveCards)
                }
            }
        
        Reduce { state, action in
            switch action {
                case .destination(.dismiss):
                    return .none
                    
                case let .loadFromContainer(container):
                    //TODO: 🍀 fix it
//                    let adFormats = container.retrieveAds(cardManager: cardManager,
//                                                          viewController: adHostingViewController,
//                                                          view: nil,
//                                                          adDelegate: adDelegate)
//                    state.adFormats = adFormats
//                    state.setName = container.settings.name
                    container.save()
                    if container.shouldUpdateAdUnits {
                        return .run { _ in
                            await showNotification(title: "File created on an other os",
                                                   message: "The file was created using a different os than iOS.\nIn order to allow it to work, the application updated all cards with the default adUnitId for each format",
                                                   notificationType: .warning)
                        }
                    } else {
                        return .none
                    }
                    
                case let .importFile(url):
                    do {
                        let container = try AdsStorableContainer.load(from: url)
                        return .send(.loadFromContainer(container))
                    } catch {
                        state.destination = .alert(.cantImportFile)
                        return .none
                    }
                    
                case let .destination(.presented(.import(.importButtonTapped(json)))):
                    do {
                        guard let data = json.data(using: .utf8) else {
                            state.destination = .alert(.cantImportFile)
                            return .send(.destination(.dismiss))
                        }
                        let container = try AdsStorableContainer.load(from: data)
                        return .merge(
                            .send(.loadFromContainer(container)),
                            .send(.destination(.dismiss))
                            )
                    } catch {
                        state.destination = .alert(.cantImportFile)
                        return .none
                    }
                    
                case .destination(.presented(.settings(.enableAdUnitEditingToggleTapped))),
                        .destination(.presented(.settings(.showCampaignToggleTapped))),
                        .destination(.presented(.settings(.showCreativeToggleTapped))),
                        .destination(.presented(.settings(.showTestModeToggleTapped))),
                        .destination(.presented(.settings(.showDspFieldsToggleTapped))),
                        .destination(.presented(.settings(.toggleKillWebviewMode))),
                        .destination(.presented(.settings(.updateKillWebviewMode))),
                        .destination(.presented(.settings(.toggleEnableFeedbacks))) :
                    if case let .settings(settingsState) = state.destination {
                        // update the cards for current settings
                        let settings = settingsState.settings
                        update(settings: settings, state: &state)
                        let formats = state.adFormats
                        state.adFormats = []
                        return .run { send in
                            try await mainQueue.sleep(for: .nanoseconds(1))
                            await send(.refreshAllCards(formats))
                        }
                    }
                    return .none
                    
                case let .refreshAllCards(formats):
                    state.adFormats = formats
                    return .none
                    
                case .binding:
                    return .none
                    
                case .showConsentButtonTapped:
                    adDelegate?.showConsentNotice(for: SettingsController().consentManager)
                    return .none
                    
                case .destination(.presented(.alert(.removeSet))):
                    state.adFormats = []
                    store(formats: [], settings: .init())
                    return .none
                    
                case .settingsButtonTapped:
                    state.destination = .settings(AppSettingsFeature.State(settings: .init(), adDelegate: adDelegate))
                    return .none
                    
                case .bulkModeButtonTapped:
                    state.destination = .alert(AlertState.notImplementedAlert("bulk mode"))
                    return .none
                    
                case .addButtonTapped:
                    state.destination = .add(.init())
                    return .none
                    
                case .addFormatButtonTapped:
                    //TODO: 🍀
//                    guard case let .add(addState) = state.destination else {
//                        return .none
//                    }
//                    let sections = addState.sections.flatMap({ $0.adFormats })
//                        .filter({ $0.nbOfFormatToLoad > 0 })
//                    for (index, _) in sections.enumerated() {
//                        if let adFormat = state.adFormats.first(where: { (key, value) in
//                            key.id == sections[index].id
//                        }) {
//                            var existingAdFormat = adFormat.key
//                            var adsManager = state.adFormats[existingAdFormat]
//                            adsManager?.append(contentsOf: adManagers(for: sections[index], startIndex: adFormat.value.count))
//                            state.adFormats[existingAdFormat] = nil
//                            existingAdFormat.nbOfFormatToLoad = adsManager?.count ?? 0
//                            state.adFormats[existingAdFormat] = adsManager
//                        } else {
//                            var newAdFormat = sections[index]
//                            let adsManager = adManagers(for: newAdFormat)
//                            newAdFormat.nbOfFormatToLoad = adsManager.count
//                            state.adFormats[newAdFormat] = adsManager
//                        }
//                        store(formats: state.adFormats)
//                    }
                    state.destination = nil
                    return .none
                    
                case .cancelAddButtonTapped:
                    state.destination = nil
                    return .none
                    
                case .exportButtonTapped:
                    let settings: SettingsContainer = .init(name: state.setName.isEmpty ? SettingsContainer.untitledAdSet : state.setName)
                    adDelegate?.share(json: AdsStorableContainer(settings: settings, cards: state.adFormats).json(),
                                      filename: state.setName.isEmpty ? SettingsContainer.untitledAdSet : state.setName)
                    return .none
                    
                case .importButtonTapped:
                    switch SettingsController().importMethod {
                        case .file:
                            adDelegate.showImportPanel()
                            
                        case .rawText:
                            state.destination = .import(.init())
                    }
                    
                    return .none
                    
                case .removeSetButtonTapped:
                    UIApplication.topViewController()?.dismiss(animated: true)
                    state.destination = .alert(AlertState.removerSetAlert())
                    return .none
                    
                case let .deleteCard(id):
                    state.removeCardFor(managerId: id)
                    return .none
                    
                case .saveCards:
                    let settings: SettingsContainer = .init(name: state.setName.isEmpty ? SettingsContainer.untitledAdSet : state.setName)
                    store(formats: state.adFormats, settings: settings)
                    return .none
                    
                case .destination(.presented(_)):
                    return .none
                    
                case.startSDKButtonTapped:
                    SdkLauncher.shared.startAds(forceStart: true)
                    return .none
                    
                case let .showLogs(show):
                    state.showLogs = show
                    var ctrl = SettingsController()
                    ctrl.showLogsSheet = show
                    return .none
                    
                case .aboutButtonTapped:
                    state.destination = .alert(.about)
                    return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    private func update(settings: SettingsContainer, state: inout State) {
        var cardEvents: [AdOptionsEvent] = []
        if state.settingsPriorToChange.showCampaignId != settings.showCampaignId {
            cardEvents.append(.showCampaignId(settings.showCampaignId))
        }
        if state.settingsPriorToChange.enableAdUnitEditing != settings.enableAdUnitEditing {
            cardEvents.append(.enableAdUnitEditing(settings.enableAdUnitEditing))
        }
        if state.settingsPriorToChange.showCreativeId != settings.showCreativeId {
            cardEvents.append(.showCreativeId(settings.showCreativeId))
        }
        if state.settingsPriorToChange.showDspFields != settings.showDspFields {
            cardEvents.append(.showDspFields(settings.showDspFields))
        }
        if state.settingsPriorToChange.bulkModeEnabled != settings.bulkModeEnabled {
            cardEvents.append(.enableBulkMode(settings.bulkModeEnabled))
        }
        if state.settingsPriorToChange.showTestMode != settings.showTestMode {
            cardEvents.append(.showTestMode(settings.showTestMode))
        }
        if state.settingsPriorToChange.enableFeedbacks != settings.enableFeedbacks {
            cardEvents.append(.enableFeedbacks(settings.enableFeedbacks))
        }
        if state.settingsPriorToChange.killWebviewMode != settings.killWebviewMode {
            cardEvents.append(.updateKillMode(settings.killWebviewMode))
        }
        state.settingsPriorToChange = settings
        state.adFormats
            .compactMap({ $0.adManagers })
            .flatMap({ $0 })
            .forEach({ adManager in
                adManager.updateCard(events: cardEvents)
            })
    }
    
    //TODO: 🍀 check it
//    private func sort(adFormats: inout [AdFormat:[any AdManager]])  {
//        var updatedValue: [AdFormat:[any AdManager]] = [:]
//        Array(adFormats.keys)
//            .sorted()
//            .forEach { key in
//                updatedValue[key] = adFormats[key]
//            }
//        adFormats = updatedValue
//    }
    
    //TODO: 🍀 Fix it
    func adManagers(for section: AdFormat, startIndex: Int = 0) -> [any AdManager] {
        var adsManager: [any AdManager] = []
//        for index in 0..<section.nbOfFormatToLoad {
//            let options = Configuration.shared.options(at: index + startIndex + 1)
//            
//            switch section.adType.adType {
//                case is AdType<InterstitialAdManager>:
//                    let interstitial: AdType<InterstitialAdManager> = section.adType.adType as! AdType<InterstitialAdManager>
//                    let interstitialManager = try? self.cardManager.adManager(for: interstitial,
//                                                                              options: options,
//                                                                              viewController: adHostingViewController,
//                                                                              adDelegate: adDelegate)
//                    adsManager.append(interstitialManager!)
//                    
//                case is AdType<RewardedAdManager>:
//                    let optin: AdType<RewardedAdManager> =  section.adType.adType as! AdType<RewardedAdManager>
//                    let optinManager = try? self.cardManager.adManager(for: optin,
//                                                                       options: options,
//                                                                       viewController: adHostingViewController,
//                                                                       adDelegate: adDelegate)
//                    adsManager.append(optinManager!)
//                    
//                case is AdType<ThumbnailAdManager>:
//                    let thumbnail: AdType<ThumbnailAdManager> =  section.adType.adType as! AdType<ThumbnailAdManager>
//                    let thumbnailManager = try? self.cardManager.adManager(for: thumbnail,
//                                                                           options: options,
//                                                                           viewController: adHostingViewController,
//                                                                           adDelegate: adDelegate)
//                    adsManager.append(thumbnailManager!)
//                    
//                case is AdType<BannerAdManager>:
//                    let banner: AdType<BannerAdManager> =  section.adType.adType as! AdType<BannerAdManager>
//                    let bannerManager = try? self.cardManager.adManager(for: banner,
//                                                                        options: options,
//                                                                        viewController: adHostingViewController,
//                                                                        adDelegate: adDelegate)
//                    adsManager.append(bannerManager!)
//                    
//                default:
//                    break
//            }
//        }
        return adsManager
    }
    
    //MARK: - Data management
    private func store(formats: [AdCardList], settings: SettingsContainer? = nil) {
        let container = AdsStorableContainer(settings: settings ?? .init(), cards: formats)
        container.save()
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case alert(AlertState<MainFeature.Action.Alert>)
            case settings(AppSettingsFeature.State)
            case add(AddFeature.State)
            case `import`(ImportFeature.State)
        }
        enum Action: Equatable {
            case alert(MainFeature.Action.Alert)
            case settings(AppSettingsFeature.Action)
            case add(AddFeature.Action)
            case `import`(ImportFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.settings, action: /Action.settings) {
                AppSettingsFeature()
            }
            Scope(state: /State.add, action: /Action.add) {
                AddFeature()
            }
            Scope(state: /State.import, action: /Action.import) {
                ImportFeature()
            }
        }
    }
}

extension AlertState where Action == MainFeature.Action.Alert {
    static var about: AlertState<Action> {
        let about = About()
        return AlertState {
            TextState("About \(about.appName)")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("""
App version: \(about.appVersion)
App build: \(about.appBuild)
Ogury Sdk : \(about.ogurySdkVersion)
Module Ads : \(about.adsSdkVersion)
Module Core : \(about.coreSdkVersion)
OM SDK version: \(about.omidVersion)
Environment: \(about.environment)
Asset key: \(about.assetKey)
Bundle Id: \(about.bundleId)
""")
        }
    }
    
    static var cantImportFile: AlertState<Action> {
        AlertState {
            TextState("Something went wrong")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState("The file cannot be opened because its content is malformed")
        }
    }
    
    static func notImplementedAlert(_ function: String) -> AlertState<Action> {
        AlertState {
            TextState("It's coming ⏰")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("Thanks")
            }
        } message: {
            TextState("The \(function) feature will soon be implemented! Stay tuned...")
        }
        
    }
    static func removerSetAlert() -> AlertState<Action> {
        AlertState {
            TextState("Clear the whole set")
        } actions: {
            ButtonState(role: .destructive, action: .removeSet) {
                TextState("Yes")
            }
            ButtonState(role: .cancel) {
                TextState("No")
            }
        } message: {
            TextState("""
You will clear the whole set of data. This action cannot be undone.
Do you want to proceed ?
""")
        }
        
    }
}

struct FormatSection: Equatable {
    let name: String
    var formats: [any AdManager] = []
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}
