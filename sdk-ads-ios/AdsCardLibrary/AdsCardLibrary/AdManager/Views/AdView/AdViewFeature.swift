//
//  AdViewFeature.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 19/07/2023.
//

import ComposableArchitecture
import Combine
import SwiftUI
import OguryAds

public enum DspRegion : CaseIterable, Codable {
    case euWest1
    case usEast1
    case usWest2
    case apNorthEast1
    
    public var displayName: String {
        switch self {
            case .euWest1: return "eu-west-1"
            case .usEast1: return "us-east-1"
            case .usWest2: return "us-west-2"
            case .apNorthEast1: return "ap-northeast-1"
        }
    }
}

public enum KillWebviewMode: String, CaseIterable, Codable {
    case none, simulate, saturate
    
    public static var allCases: [KillWebviewMode] {
#if targetEnvironment(simulator)
        return [.none, .simulate]
#else
        return [.none, .simulate, .saturate]
#endif
    }
    
    public var displayName: String {
        switch self {
            case .none: return "Don't display feature"
            case .simulate: return "Simulate"
            case .saturate: return "Crash"
        }
    }
    public var description: String? {
        switch self {
            case .none: return nil
            case .simulate: return "Simulate a memory pressure by calling the SDK delegate method that handles webview kill"
            case .saturate: return "Saturate the device's memory to try to trigger a webview crash. This will heat your device as memory will saturate, use with caution"
        }
    }
    public var displayColor: Color {
        switch self {
            case .none: return Color(AdColorPalette.Text.primary(onAccent: false).color)
            case .simulate: return Color(AdColorPalette.Text.primary(onAccent: false).color)
            case .saturate: return Color(AdColorPalette.State.failure.color)
        }
    }
    public var icon: Image? {
        if case .saturate = self {
            return Image(systemName: "bolt.trianglebadge.exclamationmark.fill")
        }
        return nil
    }
}

struct BaseOptions: Equatable {
    var adDisplayName: String = ""
    var adUnitId: String = ""
    var campaignId: String = ""
    var creativeId: String = ""
    var dspCreativeId: String = ""
    var dspRegion: DspRegion = .euWest1
    var showCampaignId: Bool = false
    var showCreativeId: Bool = true
    var showDspFields: Bool = true
    var showSpecificOptions: Bool = true
    var bulkModeEnabled = false
    var isSelected = false
    var oguryTestModeEnabled: Bool = false
    var rtbTestModeEnabled: Bool = false
    var qaLabel: String = UUID().uuidString
    var killWebviewMode: KillWebviewMode = .none
    
    init(from options: any AdOptions) {
        showCampaignId = options.showCampaignId
        showCreativeId = options.showCreativeId
        showDspFields = options.showDspFields
        showSpecificOptions = options.showSpecificOptions
        adDisplayName = options.baseOptions.adDisplayName
        adUnitId = options.baseOptions.adUnitId
        campaignId = options.baseOptions.campaignId ?? ""
        creativeId = options.baseOptions.creativeId ?? ""
        dspCreativeId = options.baseOptions.dspCreativeId ?? ""
        dspRegion = options.baseOptions.dspRegion ?? .euWest1
        bulkModeEnabled = options.baseOptions.bulkModeEnabled
        isSelected = options.baseOptions.isSelected
        oguryTestModeEnabled = options.baseOptions.oguryTestModeEnabled
        rtbTestModeEnabled = options.baseOptions.rtbTestModeEnabled
        qaLabel = options.baseOptions.qaLabel
        killWebviewMode = options.baseOptions.killWebviewMode
    }
}

struct BannerContainer: Equatable {
    var bannerAd: OguryBannerAdView?
    var bannerType: AdType<BannerAdManager>
}

public extension OguryLogType {
    static let testApp: OguryLogType = .init("TestApp")
    static let receivedCallbacks: OguryLogType = .init("ReceivedCallbacks")
}

struct AdViewFeature: Reducer {
    var adManager: any AdManager
    
    struct State: Equatable {
        static func == (lhs: AdViewFeature.State, rhs: AdViewFeature.State) -> Bool {
            let isEqual = lhs.adStateEvent == rhs.adStateEvent &&
            lhs.isLoading == rhs.isLoading &&
            ((lhs.error == nil && rhs.error == nil) || (lhs.error != nil && rhs.error != nil)) &&
            lhs.baseOptions == rhs.baseOptions &&
            lhs.showTestModeButton == rhs.showTestModeButton &&
            ((lhs.thumbnailOptions == nil && rhs.thumbnailOptions == nil) || (lhs.thumbnailOptions != rhs.thumbnailOptions))
            return isEqual
        }
        
        @BindingState var baseOptions: BaseOptions
        var testModeOptions: BaseOptions {
            var options = baseOptions
            options.campaignId = ""
            options.creativeId = ""
            options.dspCreativeId = ""
            return options
        }
        var isLoading = false
        var error: Error?
        var showAfterLoad = false
        var adStateEvent: AdLifeCycleEvent?
        var specificOptions: any AdOptions
        var thumbnailOptions: ThumbnailDisplayOptions?
        var bannerContainer: BannerContainer?
        var rewardedOptions: RewardedOptions?
        var testModeEnabled: Bool {
            get {
                baseOptions.oguryTestModeEnabled
            }
            set {
                baseOptions.oguryTestModeEnabled = newValue
            }
        }
        var rtbTestModeEnabled: Bool {
            get {
                baseOptions.rtbTestModeEnabled
            }
            set {
                baseOptions.rtbTestModeEnabled = newValue
            }
        }
        var showTestModeButton = true
        var enableAdUnitEditing = true
        var enableFeedbacks = true
        let id: UUID = UUID()
        let adType: AnyAdType!
        var enableRtbTestMode: Bool {
            if let ad = (adType.adType as? AdType<InterstitialAdManager>) {
                return ad.enableRtbTestMode
            }
            if let ad = (adType.adType as? AdType<RewardedAdManager>) {
                return ad.enableRtbTestMode
            }
            if let ad = (adType.adType as? AdType<ThumbnailAdManager>) {
                return ad.enableRtbTestMode
            }
            if let ad = (adType.adType as? AdType<BannerAdManager>) {
                return ad.enableRtbTestMode
            }
            return false
        }
        // this field is used to show the content od the various fields when the test mode is enabled
        // since we need a Binding to a String, we wille use this property
        @BindingState var fakeTextState = ""
        @PresentationState var alert: AlertState<Action.Alert>?
        var tags: Set<OguryAdTag> = Set()
        
        private var adUnitIsInTestMode: Bool { baseOptions.adUnitId.isTestModeOn }
        
        @discardableResult mutating func updateTestMode() -> Bool {
            let previousMode = testModeEnabled
            testModeEnabled = adUnitIsInTestMode
            if testModeEnabled {
                tags.insert(.oguryTestMode)
            } else {
                tags.remove(.oguryTestMode)
            }
            return previousMode != testModeEnabled
        }
        mutating func toggleTestMode() {
            if adUnitIsInTestMode {
                baseOptions.adUnitId.removeLast(5)
                tags.remove(.oguryTestMode)
            } else {
                baseOptions.adUnitId.append(AdsCardManager.testModeSuffix)
                tags.insert(.oguryTestMode)
            }
        }
        mutating func forceTestMode(_ enable: Bool) {
            if !adUnitIsInTestMode && enable {
                baseOptions.adUnitId.append(AdsCardManager.testModeSuffix)
                tags.insert(.oguryTestMode)
            } else if adUnitIsInTestMode && !enable {
                baseOptions.adUnitId.removeLast(5)
                tags.remove(.oguryTestMode)
            }
        }
        
        var actionBar: AdActionBarFeature.State {
            get {
                AdActionBarFeature.State(qaLabel: baseOptions.qaLabel)
            }
            
            set {}
        }
        var bannerFeature: BannerPlaceholderFeature.State {
            get {
                return BannerPlaceholderFeature.State(bannerAd: bannerContainer?.bannerAd, bannerType: bannerContainer?.bannerType ?? .banner)
            }
            
            set {
                bannerContainer?.bannerAd = newValue.bannerAd
            }
        }
        var thumbFeature: ThumbnailOptionFeature.State {
            get {
                ThumbnailOptionFeature.State(options: thumbnailOptions!)
            }
            
            set {
                thumbnailOptions = newValue.options
            }
        }
        var rewardedFeature: RewardedFeature.State {
            get {
                RewardedFeature.State(name: rewardedOptions?.name ?? "",
                                      value: rewardedOptions?.value ?? "",
                                      rewardReceived: rewardedOptions?.received ?? false)
            }
            
            set {
                rewardedOptions = RewardedOptions(name: newValue.name, value: newValue.value, received: newValue.rewardReceived)
            }
        }
        
        init(from options: any AdOptions,
             adType: AnyAdType,
             bannerContainer: BannerContainer? = nil,
             rewardedOptions: RewardedOptions? = nil) {
            baseOptions = BaseOptions(from: options)
            specificOptions = options
            if options as? ThumbnailAdManagerOptions != nil {
                thumbnailOptions = ThumbnailDisplayOptions(showOptions: options.showSpecificOptions)
            }
            self.bannerContainer = bannerContainer
            self.rewardedOptions = rewardedOptions
            self.adType = adType
            updateTags()
            UISegmentedControl.appearance().selectedSegmentTintColor = AdColorPalette.Primary.accent.color
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: AdColorPalette.Primary.accent.color], for: .normal)
        }
        
        mutating func updateTags() {
            updateTestMode()
            updateRTBTag()
        }
        
        mutating func updateRTBTag() {
            if rtbTestModeEnabled {
                tags.insert(.rtbTestMode)
            } else {
                tags.remove(.rtbTestMode)
            }
        }
        
        func log(_ message: String, logType: OguryLogType = .testApp) {
            AdsCardManager.logger?.logMessage(OGAAdLogMessage(level: .debug,
                                                              logType: logType,
                                                              origin: baseOptions.qaLabel,
                                                              sdk: .ads,
                                                              messageDate: nil,
                                                              message: message,
                                                              tags: nil))
        }
        
        // log received publisher callbacks only
        func log(event: AdLifeCycleEvent) {
            var message: String? = nil
            switch event {
                case .adLoading: () // no publisher callback
                case .adLoaded: message = "Ad loaded"
                case .adDisplaying: () // no publisher callback
                case .adClicked: message = "Ad clicked"
                case .adClosed: message = "Ad closed"
                case .adDidTriggerImpression: message = "Ad triggered impression"
                case .bannerReady: () // no publisher callback
                case .rewardReady(let reward): message = "Ad received reward (\(reward.rewardName) : \(reward.rewardValue))"
                case .adDidFailToLoad(let error): message = "Ad failed to load (\(error.displayMessage))"
                case .adDidFailToDisplay(let error): message = "Ad failed to show (\(error.displayMessage))"
                case .adDidFail(let error): message = "Ad failed (\(error.displayMessage))"
            }
            if let message { log(message, logType: .receivedCallbacks) }
        }
    }
    
    enum Action: BindableAction, Equatable  {
        static func == (lhs: AdViewFeature.Action, rhs: AdViewFeature.Action) -> Bool {
            switch (lhs, rhs) {
                case (let .binding(lhsValue), let .binding(rhsValue)): return lhsValue == rhsValue
                case (let .updateEvent(lhsValue), let .updateEvent(rhsValue)): return lhsValue == rhsValue
                case (let .adBarAction(lhsValue), let .adBarAction(rhsValue)): return lhsValue == rhsValue
                case (let .bannerAction(lhsValue), let .bannerAction(rhsValue)): return lhsValue == rhsValue
                case (let .thumbnailOptionsAction(lhsValue), let .thumbnailOptionsAction(rhsValue)): return lhsValue == rhsValue
                case (.showOptionToggle,showOptionToggle): return true
                case (let .error(lhsError), let .error(rhsError)): return areEqual(lhsError, rhsError)
                default: return false
            }
        }
        
        case binding(BindingAction<State>)
        case updateEvent(_: AdLifeCycleEvent)
        case adBarAction(_: AdActionBarFeature.Action)
        case bannerAction(_: BannerPlaceholderFeature.Action)
        case rewardedAction(_: RewardedFeature.Action)
        case resetReward
        case resetBanner
        case bannerReady(_: OguryBannerAdView)
        case rewardReady(_: OguryReward)
        case thumbnailOptionsAction(_: ThumbnailOptionFeature.Action)
        case showOptionToggle
        case showAfterLoad
        case error(_: Error)
        case alert(PresentationAction<Alert>)
        // options
        case enableAdUnitEditing(_: Bool)
        case showCampaignId(_: Bool)
        case showCreativeId(_: Bool)
        case showDspFields(_: Bool)
        case showSpecificOptions(_: Bool)
        case enableBulkMode(_: Bool)
        // test mode
        case showTestModeButton(_: Bool)
        case checkForTestMode
        case oguryTestModeButtonTapped
        case rtbTestModeButtonTapped
        case forceTestMode(_: Bool)
        case enableFeedbacks(_: Bool)
        case showQALabelTapped
        case killWebview
        case updateKillMode(_: KillWebviewMode)
        
        enum Alert {
            case confirmDelete
        }
    }
    
    enum AdCancel: Hashable {
        case load(_: UUID), show(_: UUID)
    }
    
    func load(state: State) -> Effect<AdViewFeature.Action> {
        .merge(
            .cancel(id: AdCancel.load(state.id)),
            .publisher { [state] in
                adManager
                    .events
                    .receive(on: DispatchQueue.main)
                    .map { event in
                        state.log(event: event)
                        switch event {
                            case let .adLoaded(canShow):
                                if state.enableFeedbacks {
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }
                                if state.showAfterLoad, canShow {
                                    return .showAfterLoad
                                }
                                return event.action
                                
                            case .adDidFailToLoad, .adDidFailToDisplay, .adDidFail:
                                if state.enableFeedbacks {
                                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                                }
                                fallthrough
                                
                            default:
                                return event.action
                        }
                    }
            }.cancellable(id: AdCancel.load(state.id)),
            .run { [state] send in
                do {
                    guard var options = adManager.options?.baseOptions else {
                        throw AdManagerError.noOptions
                    }
                    let testMode = state.testModeEnabled
                    options.adUnitId = state.baseOptions.adUnitId
                    options.campaignId = testMode ? nil : state.baseOptions.campaignId
                    options.creativeId = testMode ? nil : state.baseOptions.creativeId
                    options.dspCreativeId = testMode ? nil : state.baseOptions.dspCreativeId
                    options.dspRegion = (!state.baseOptions.showDspFields || testMode) ? nil : state.baseOptions.dspRegion
                    options.adDisplayName = state.baseOptions.adDisplayName
                    if let thumbManager = adManager as? ThumbnailAdManager,
                       let thumbOptions = state.thumbnailOptions {
                        thumbManager.updateOptions(from: thumbOptions)
                    }
                    try adManager.loadAd(from: options)
                    await send(.resetReward)
                } catch {
                    await send(.error(error))
                    
                }
            }.cancellable(id: AdCancel.load(state.id))
        )
    }
    
    private func updateAdManager(options: BaseOptions) {
        adManager.update(options: BaseAdOptions(adDisplayName: options.adDisplayName,
                                                adUnitId: options.adUnitId,
                                                campaignId: options.campaignId,
                                                dspCreativeId: options.dspCreativeId,
                                                dspRegion: options.dspRegion, creativeId: options.creativeId,
                                                isSelected: options.isSelected,
                                                bulkModeEnabled: options.bulkModeEnabled,
                                                oguryTestModeEnabled:options.oguryTestModeEnabled,
                                                rtbTestModeEnabled:options.rtbTestModeEnabled,
                                                killWebviewMode: options.killWebviewMode,
                                                qaLabel:options.qaLabel))
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.baseOptions, { oldValue, newValue in
                Reduce { state, action in
                    updateAdManager(options: newValue)
                    return .none
                }
            })
            .onChange(of: \.baseOptions.adUnitId, { oldValue, newValue in
                Reduce {state, action in
                    return .send(.checkForTestMode)
                }
            })
            .onChange(of: \.thumbnailOptions, { oldValue, newValue in
                Reduce { state, action in
                    if let thumbManager = adManager as? ThumbnailAdManager, let newValue {
                        thumbManager.updateOptions(from: newValue)
                    }
                    return .none
                }
            })
        Scope(state: \.actionBar,
              action: /Action.adBarAction,
              child: { AdActionBarFeature() }
        )
        Scope(state: \.thumbFeature,
              action: /Action.thumbnailOptionsAction,
              child: { ThumbnailOptionFeature() }
        )
        Scope(state: \.bannerFeature,
              action: /Action.bannerAction,
              child: { BannerPlaceholderFeature()._printChanges() }
        )
        Scope(state: \.rewardedFeature,
              action: /Action.rewardedAction,
              child: { RewardedFeature() }
        )
        Reduce { state, action in
            switch action {
                case .alert(.presented(.confirmDelete)):
                    adManager.adDelegate?.deleteCard(withId: adManager.id)
                    return .none
                    
                case .alert:
                    return .none
                    
                case .binding:
                    return .none
                    
                case .resetReward:
                    if state.rewardedOptions != nil {
                        state.rewardedOptions = RewardedOptions(name: "", value: "", received: false)
                    }
                    return .none
                    
                case .resetBanner:
                    state.bannerContainer?.bannerAd = nil
                    return .none
                    
                case .rewardedAction:
                    return .none
                    
                case let .rewardReady(reward):
                    let name = reward.rewardName.isEmpty ? "Empty name" : reward.rewardName
                    let value = reward.rewardValue.isEmpty ? "Empty value" : reward.rewardValue
                    if state.rewardedOptions != nil {
                        state.rewardedOptions?.name = name
                        state.rewardedOptions?.value = value
                        state.rewardedOptions?.received = true
                    } else {
                        state.rewardedOptions = RewardedOptions(name: name, value: value, received: true)
                    }
                    return .none
                    
                case let .bannerReady(ad):
                    state.bannerContainer?.bannerAd = ad
                    let bannerType = state.bannerFeature.bannerType
                    state.bannerFeature = BannerPlaceholderFeature.State(bannerAd: ad, bannerType: bannerType)
                    return .none
                    
                case let .updateEvent(event):
                    print("☠️ \(event)")
                    state.adStateEvent = event
                    if event == .adClosed {
                        state.bannerContainer?.bannerAd = nil
                        let bannerType = state.bannerFeature.bannerType
                        state.bannerFeature = BannerPlaceholderFeature.State(bannerAd: nil, bannerType: bannerType)
                    }
                    return .none
                    
                case let .adBarAction(action):
                    switch action {
                        case .loadButtonTapped:
                            state.log("Load button tapped")
                            state.showAfterLoad = false
                            if state.enableFeedbacks {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            return load(state: state)
                            
                        case .showButtonTapped:
                            state.log("Show button tapped")
                            state.showAfterLoad = false
                            if state.enableFeedbacks {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            return .merge(
                                .cancel(id: AdCancel.show(state.id)),
                                .publisher {
                                    adManager
                                        .events
                                        .receive(on: DispatchQueue.main)
                                        .map { [state] event in
                                            state.log(event: event)
                                            return event.action
                                        }
                                }.cancellable(id: AdCancel.show(state.id)),
                                .run { send in
                                    do {
                                        try adManager.showAd()
                                    } catch {
                                        await send(.error(error))
                                    }
                                }.cancellable(id: AdCancel.show(state.id))
                            )
                            
                        case .loadAndShowButtonTapped:
                            state.log("Load & Show button tapped")
                            state.showAfterLoad = true
                            if state.enableFeedbacks {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            return load(state: state)
                            
                        case .deleteButtonTapped:
                            state.log("Delete button tapped")
                            if state.enableFeedbacks {
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            }
                            state.alert = AlertState(
                                title: {
                                    TextState("Do you want to delete this card ? ")
                                }, actions: {
                                    ButtonState(role: .destructive, action: .confirmDelete, label: { TextState("Delete") })
                                })
                            return .none
                    }
                    
                case .showAfterLoad:
                    state.showAfterLoad = false
                    return .send(.adBarAction(.showButtonTapped))
                    
                case .thumbnailOptionsAction:
                    return .none
                    
                case .bannerAction:
                    (adManager as? BannerAdManager)?.closeAd()
                    return .none
                    
                case .showOptionToggle:
                    state.baseOptions.showSpecificOptions.toggle()
                    return .none
                    
                case let .error(error):
                    state.log("Error received \(error.localizedDescription)")
                    state.error = error
                    state.adStateEvent = .adDidFail(error)
                    return .none
                    
                case let .showCampaignId(value):
                    state.baseOptions.showCampaignId = value
                    // if the field is hidden, we "nil" it out
                    if value {
                        state.baseOptions.campaignId = ""
                    }
                    return .none
                    
                case let .showCreativeId(value):
                    state.baseOptions.showCreativeId = value
                    // if the field is hidden, we "nil" it out
                    if value {
                        state.baseOptions.creativeId = ""
                    }
                    return .none
                    
                case let .showDspFields(value):
                    state.baseOptions.showDspFields = value
                    // if the field is hidden, we "nil" it out
                    if value {
                        state.baseOptions.dspCreativeId = ""
                    }
                    return .none
                    
                case let .showSpecificOptions(value):
                    guard state.thumbnailOptions != nil else { return .none }
                    state.baseOptions.showSpecificOptions = value
                    var current = state.thumbFeature
                    current.options.showOptions = value
                    state.thumbFeature = current
                    return .none
                    
                case let .enableBulkMode(value):
                    state.baseOptions.bulkModeEnabled = value
                    return .none
                    
                    // test mode
                case let .showTestModeButton(show):
                    state.showTestModeButton = show
                    return .none
                    
                case .checkForTestMode:
                    let update = state.updateTestMode()
                    // the options are not updated when setting the adUnit programmatically, so we have to "force" an option update
                    if update {
                        updateAdManager(options: state.testModeEnabled ? state.testModeOptions : state.baseOptions)
                    }
                    return .none
                    
                case .oguryTestModeButtonTapped:
                    state.log("Ogury test mode button tapped")
                    state.toggleTestMode()
                    return .send(.checkForTestMode)
                    
                case .rtbTestModeButtonTapped:
                    state.log("RTBTest mode button tapped")
                    state.rtbTestModeEnabled.toggle()
                    state.updateRTBTag()
                    updateAdManager(options: state.baseOptions)
                    return .none
                    
                case let .forceTestMode(enable):
                    state.forceTestMode(enable)
                    return .send(.checkForTestMode)
                    
                case let .enableFeedbacks(enable):
                    state.enableFeedbacks = enable
                    return .none
                    
                case let .enableAdUnitEditing(value):
                    state.enableAdUnitEditing = value
                    return .none
                    
                case .showQALabelTapped:
                    adManager.adDelegate?.focusLogs(on: state.baseOptions.qaLabel)
                    return .none
                    
                case .killWebview:
                    adManager.killWebview(state.baseOptions.killWebviewMode)
                    return .none
                    
                case let .updateKillMode(mode):
                    state.baseOptions.killWebviewMode = mode
                    return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}

extension AdLifeCycleEvent {
    var action: AdViewFeature.Action {
        switch self {
            case let .adDidFailToLoad(error): return .error(error)
            case let .adDidFailToDisplay(error): return .error(error)
            case let .adDidFail(error): return .error(error)
            case let .bannerReady(ad): return .bannerReady(ad)
            case let .rewardReady(reward): return .rewardReady(reward)
            default: return .updateEvent(self)
        }
    }
}

extension Error {
    var displayMessage: String {
        if let adError = self as? OguryAdError {
            return "#\(adError.code) : \(adError.localizedDescription)"
        }
        return String(describing: self)
    }
}
