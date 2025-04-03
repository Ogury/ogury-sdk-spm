//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture
import AdsCardLibrary
import SwiftUI
import OguryAds
import OguryCore
import OMSDK_Ogury

struct About {
    var appName: String { Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Ads Test Application" }
    var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String }
    var appBuild: String { Bundle.main.infoDictionary?["CFBundleVersion"] as! String }
    var environment: String { Bundle.main.object(forInfoDictionaryKey: "DefaultEnv") as? String ?? "" }
    var bundleId: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "" }
    var omidVersion: String { OMIDOgurySDK.versionString() }
    var assetKey: String { AdSdkLauncher.shared.assetKey }
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
    let maxHeaderBidable = MaxBidder()
    let dtFairBidHeaderBidable = DTFairBidBidder()
    let unityLevelPlayBidable = UnityLevelPlayBidder()
    
    struct State: Equatable {
        static func == (lhs: MainFeature.State, rhs: MainFeature.State) -> Bool {
            var isEqual = true
            guard lhs.adFormats.count == rhs.adFormats.count,
                  lhs.showLogs == rhs.showLogs else { return false }
            lhs.adFormats.forEach { (key, value) in
                if !rhs.adFormats.keys.contains(key) {
                    isEqual = false
                    return
                }
                if value.count != rhs.adFormats[key]!.count {
                    isEqual = false
                    return
                }
                let leftFormats = lhs.adFormats.compactMap({ $0.value }).flatMap{ $0 }
                let rightFormats = rhs.adFormats.compactMap({ $0.value }).flatMap{ $0 }
                zip(leftFormats,
                    rightFormats)
                .forEach { lhsManager, rhsManager in
                    if lhsManager.options.baseOptions != rhsManager.options.baseOptions ||
                        (lhsManager.options as? BaseAdManagerOptions) != (rhsManager.options as? BaseAdManagerOptions) ||
                        (lhsManager.options as? ThumbnailAdManagerOptions) != (rhsManager.options as? ThumbnailAdManagerOptions) {
                        isEqual = false
                        return
                    }
                }
            }
            return isEqual && lhs.destination == rhs.destination && lhs.setName == rhs.setName
        }
        
        var adFormats: [AdFormat:[any OguryAdManager]] = [:]
        @PresentationState var destination: Destination.State?
        @BindingState var setName = ""
        fileprivate var settingsPriorToChange: SettingsContainer = SettingsContainer()
        var showLogs = SettingsController().showLogsSheet
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
        case refreshAllCards(_: [AdFormat:[any OguryAdManager]])
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
                    let adFormats = container.retrieveAds(cardManager: cardManager,
                                                          maxHeaderBidable: maxHeaderBidable,
                                                          dtFairBidHeaderBidable: dtFairBidHeaderBidable,
                                                          unityLevelPlayBidable: unityLevelPlayBidable,
                                                          viewController: adHostingViewController,
                                                          view: nil,
                                                          adDelegate: adDelegate)
                    state.adFormats = adFormats
                    state.setName = container.settings.name
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
                        .destination(.presented(.settings(.showSpecificOptionsToggleTapped))),
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
                        state.adFormats = [:]
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
                    state.adFormats = [:]
                    store(formats: [:], settings: .init())
                    return .none
                    
                case .settingsButtonTapped:
                    state.destination = .settings(AppSettingsFeature.State(settings: .init(), adDelegate: adDelegate))
                    return .none
                    
                case .bulkModeButtonTapped:
                    state.destination = .alert(AlertState.notImplementedAlert("bulk mode"))
                    return .none
                    
                case .addButtonTapped:
                    state.destination = .add(.init(maxHeaderBidable: maxHeaderBidable, dtFairBidHeaderBidable: dtFairBidHeaderBidable, unityLevelPlayBidable: unityLevelPlayBidable))
                    return .none
                    
                case .addFormatButtonTapped:
                    guard case let .add(addState) = state.destination else {
                        return .none
                    }
                    let sections = addState.sections.flatMap({ $0.adFormats })
                        .filter({ $0.nbOfFormatToLoad > 0 })
                    for (index, _) in sections.enumerated() {
                        if let adFormat = state.adFormats.first(where: { (key, value) in
                            key.id == sections[index].id
                        }) {
                            var existingAdFormat = adFormat.key
                            var adsManager = state.adFormats[existingAdFormat]
                            adsManager?.append(contentsOf: adManagers(for: sections[index], startIndex: adFormat.value.count))
                            state.adFormats[existingAdFormat] = nil
                            existingAdFormat.nbOfFormatToLoad = adsManager?.count ?? 0
                            state.adFormats[existingAdFormat] = adsManager
                        } else {
                            var newAdFormat = sections[index]
                            let adsManager = adManagers(for: newAdFormat)
                            newAdFormat.nbOfFormatToLoad = adsManager.count
                            state.adFormats[newAdFormat] = adsManager
                        }
                        store(formats: state.adFormats)
                    }
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
                    let formats = removeCard(withId: id, from: state.adFormats)
                    state.adFormats = formats
                    store(formats: formats)
                    return .none
                    
                case .saveCards:
                    let settings: SettingsContainer = .init(name: state.setName.isEmpty ? SettingsContainer.untitledAdSet : state.setName)
                    store(formats: state.adFormats, settings: settings)
                    return .none
                    
                case .destination(.presented(_)):
                    return .none
                    
                case.startSDKButtonTapped:
                    AdSdkLauncher.shared.startAds(forceStart: true)
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
        if state.settingsPriorToChange.showSpecificOptions != settings.showSpecificOptions {
            cardEvents.append(.showSpecificOptions(settings.showSpecificOptions))
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
        state
            .adFormats
            .compactMap({ $0.value })
            .flatMap({ $0 })
            .forEach({ adManager in
                adManager.updateCard(events: cardEvents)
            })
    }
    
    private func sort(adFormats: inout [AdFormat:[any OguryAdManager]])  {
        var updatedValue: [AdFormat:[any OguryAdManager]] = [:]
        Array(adFormats.keys)
            .sorted()
            .forEach { key in
                updatedValue[key] = adFormats[key]
            }
        adFormats = updatedValue
    }
    
    func adManagers(for section: AdFormat, startIndex: Int = 0) -> [any OguryAdManager] {
        var adsManager: [any OguryAdManager] = []
        for index in 0..<section.nbOfFormatToLoad {
            switch section.adType.adType {
                case is AdType<InterstitialAdManager>:
                    let interstitial: AdType<InterstitialAdManager> = section.adType.adType as! AdType<InterstitialAdManager>
                    let options = Configuration.shared.options(for: interstitial, index: index + startIndex + 1)
                    options.viewController = adHostingViewController
                    let interstitialManager = try? self.cardManager.adManager(for: interstitial,
                                                                              options: options,
                                                                              adDelegate: adDelegate)
                    adsManager.append(interstitialManager!)
                    
                case is AdType<RewardedAdManager>:
                    let optin: AdType<RewardedAdManager> =  section.adType.adType as! AdType<RewardedAdManager>
                    let options = Configuration.shared.options(for: optin, index: index + startIndex + 1)
                    options.viewController = adHostingViewController
                    let optinManager = try? self.cardManager.adManager(for: optin,
                                                                       options: options,
                                                                       adDelegate: adDelegate)
                    adsManager.append(optinManager!)
                    
                case is AdType<ThumbnailAdManager>:
                    let thumbnail: AdType<ThumbnailAdManager> =  section.adType.adType as! AdType<ThumbnailAdManager>
                    let options = Configuration.shared.options(for: thumbnail, index: index + startIndex + 1)
                    options.viewController = adHostingViewController
                    let thumbnailManager = try? self.cardManager.adManager(for: thumbnail,
                                                                           options: options,
                                                                           adDelegate: adDelegate)
                    adsManager.append(thumbnailManager!)
                    
                case is AdType<BannerAdManager>:
                    let banner: AdType<BannerAdManager> =  section.adType.adType as! AdType<BannerAdManager>
                    let options = Configuration.shared.options(for: banner, index: index + startIndex + 1)
                    let bannerManager = try? self.cardManager.adManager(for: banner,
                                                                        options: options,
                                                                        adDelegate: adDelegate)
                    adsManager.append(bannerManager!)
                    
                default:
                    break
            }
        }
        return adsManager
    }
    
    private func removeCard(withId id: UUID, from formats: [AdFormat:[any OguryAdManager]]) -> [AdFormat:[any OguryAdManager]] {
        var sections = formats
        sections.keys.forEach { key in
            var newKey = key
            var values = sections[key] ?? []
            values.removeAll(where: { $0.id == id })
            if values.isEmpty {
                sections[key] = nil
            } else {
                newKey.nbOfFormatToLoad = values.count
                sections[key] = nil
                sections[newKey] = values
            }
        }
        return sections
    }
    
    //MARK: - Data management
    private func store(formats: [AdFormat:[any OguryAdManager]], settings: SettingsContainer? = nil) {
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
    var formats: [any OguryAdManager] = []
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}

extension AdType {
    var sectionName: String {
        switch self {
            case .interstitial: return "Interstitial"
            case .rewarded: return "Rewarded Video"
            case .thumbnail: return "Thumbnail"
            case .mpu: return "MREC"
            case .banner: return "Small banner"
            case let .maxHeaderBidding(innerFormat, _): return "MAX HB - \(innerFormat.sectionName)"
            case let .dtFairBidHeaderBidding(innerFormat, _): return "DT Fair Bid HB - \(innerFormat.sectionName)"
            case let .unityLevelPlayHeaderBidding(innerFormat, _): return "Unity LevelPlay HB - \(innerFormat.sectionName)"
            @unknown default:
                fatalError()
        }
    }
}
