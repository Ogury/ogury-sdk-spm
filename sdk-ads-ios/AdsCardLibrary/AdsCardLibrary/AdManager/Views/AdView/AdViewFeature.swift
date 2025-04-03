//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
internal import ComposableArchitecture
import OguryAds

@Reducer
struct AdViewFeature {
    @ObservableState
    struct State: Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.adManager.adConfiguration == rhs.adManager.adConfiguration
            && lhs.adManager.cardConfiguration == rhs.adManager.cardConfiguration
            && lhs.adManager.lifeCycleEvents == rhs.adManager.lifeCycleEvents
            && lhs.adStateEvent == rhs.adStateEvent
            && lhs.isLoading == rhs.isLoading
            && ((lhs.error == nil && rhs.error == nil) || (lhs.error != nil && rhs.error != nil))
        }
        
        //MARK: init
        var adManager: any AdManager
        init(adManager: inout any AdManager) {
            self.adManager = adManager
            switch adManager.adFormat {
                case .rewardedVideo: rewardedOptions = .init()
                case .smallBanner, .mrec: bannerContainer = .init(bannerType: adManager.adFormat)
                case .interstitial, .thumbnail: ()
            }
        }
        
        //MARK: Properties
        // this field is used to show the content od the various fields when the test mode is enabled
        // since we need a Binding to a String, we wille use this property
        var fakeTextState: String = ""
        
        @Presents var alert: AlertState<Action.Alert>?
        var tags: Set<OguryAdTag> = Set()
        var enableFeedbacks = true
        var isLoading = false
        var error: Error?
        var showAfterLoad = false
        var bannerContainer: BannerContainer?
        var rewardedOptions: RewardedOptions?
        var adStateEvent: AdLifeCycleEvent?
        
        private var adUnitIsInTestMode: Bool { adManager.adConfiguration.adUnitId.isTestModeOn }
        //MARK: TCA bridges
        var actionBar: AdActionBarFeature.State {
            get {
                AdActionBarFeature.State(qaLabel: adManager.cardConfiguration.qaLabel)
            }
            
            set {}
        }
        var bannerFeature: BannerPlaceholderFeature.State {
            get {
                return BannerPlaceholderFeature.State(bannerAd: bannerContainer?.bannerAd,
                                                      bannerType: adManager.adFormat)
            }
            
            set {
                bannerContainer?.bannerAd = newValue.bannerAd
            }
        }
        var rewardedFeature: RewardedFeature.State {
            get {
                RewardedFeature.State(name: rewardedOptions?.name ?? "",
                                      value: rewardedOptions?.value ?? "",
                                      rewardReceived: rewardedOptions?.received ?? false)
            }
            
            set {
                rewardedOptions = RewardedOptions(name: newValue.name,
                                                  value: newValue.value,
                                                  received: newValue.rewardReceived)
            }
        }
        
        //MARK: functionnalities
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
                adManager.adConfiguration.adUnitId.removeLast(5)
                tags.remove(.oguryTestMode)
            } else {
                adManager.adConfiguration.adUnitId.append(AdsCardManager.testModeSuffix)
                tags.insert(.oguryTestMode)
            }
        }
        mutating func forceTestMode(_ enable: Bool) {
            if !adUnitIsInTestMode && enable {
                adManager.adConfiguration.adUnitId.append(AdsCardManager.testModeSuffix)
                tags.insert(.oguryTestMode)
            } else if adUnitIsInTestMode && !enable {
                adManager.adConfiguration.adUnitId.removeLast(5)
                tags.remove(.oguryTestMode)
            }
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
                                                              origin: adManager.cardConfiguration.qaLabel,
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
                case let .rewardReady(rewardName, rewardValue): message = "Ad received reward (\(rewardName) : \(rewardValue))"
                case .adDidFailToLoad(let error): message = "Ad failed to load (\(error.displayMessage))"
                case .adDidFailToDisplay(let error): message = "Ad failed to show (\(error.displayMessage))"
                case .adDidFail(let error): message = "Ad failed (\(error.displayMessage))"
            }
            if let message { log(message, logType: .receivedCallbacks) }
        }
    }
    
    enum Action: BindableAction, Equatable  {
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
                case (let .binding(lhsValue), let .binding(rhsValue)): return lhsValue == rhsValue
                case (let .updateEvent(lhsValue), let .updateEvent(rhsValue)): return lhsValue == rhsValue
                case (let .adBarAction(lhsValue), let .adBarAction(rhsValue)): return lhsValue == rhsValue
                case (let .bannerAction(lhsValue), let .bannerAction(rhsValue)): return lhsValue == rhsValue
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
        case bannerReady(_: UIView)
        case rewardReady(name: String, value: String)
        case showAfterLoad
        case error(_: Error)
        case alert(PresentationAction<Alert>)
        // options
        case enableAdUnitEditing(_: Bool)
        case showCampaignId(_: Bool)
        case showCreativeId(_: Bool)
        case showDspFields(_: Bool)
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
        
        @CasePathable
        enum Alert: Equatable {
            case confirmDelete
        }
        
        static let actionBarCasePath =  AnyCasePath<Action, AdActionBarFeature.Action>(
            embed: { .adBarAction($0) },
            extract: { if case let .adBarAction(value) = $0 { return value} else { return nil } }
        )
        static let bannerCasePath =  AnyCasePath<Action, BannerPlaceholderFeature.Action>(
            embed: { .bannerAction($0) },
            extract: { if case let .bannerAction(value) = $0 { return value} else { return nil } }
        )
        static let rewardCasePath =  AnyCasePath<Action, RewardedFeature.Action>(
            embed: { .rewardedAction($0) },
            extract: { if case let .rewardedAction(value) = $0 { return value} else { return nil } }
        )
    }
    
    enum NewAdCancel: Hashable {
        case load(_: UUID), show(_: UUID)
    }
    
    func load(_ state: State) -> Effect<AdViewFeature.Action> {
        .merge(
            .cancel(id: NewAdCancel.load(state.adManager.id)),
            .publisher { [state] in
                state
                    .adManager
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
                                return event.newAction
                                
                            case .adDidFailToLoad, .adDidFailToDisplay, .adDidFail:
                                if state.enableFeedbacks {
                                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                                }
                                fallthrough
                                
                            default:
                                return event.newAction
                        }
                    }
            }.cancellable(id: NewAdCancel.load(state.adManager.id)),
            .run { [state] send in
                state.adManager.load()
                await send(.resetReward)
            }.cancellable(id: NewAdCancel.load(state.adManager.id))
        )
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.actionBar,
              action: Action.actionBarCasePath,
              child: { AdActionBarFeature() }
        )
        Scope(state: \.bannerFeature,
              action: Action.bannerCasePath,
              child: { BannerPlaceholderFeature()._printChanges() }
        )
        Scope(state: \.rewardedFeature,
              action: Action.rewardCasePath,
              child: { RewardedFeature() }
        )
        Reduce { state, action in
            switch action {
                case .alert(.presented(.confirmDelete)):
                    state.adManager.adDelegate?.deleteCard(withId: state.adManager.id)
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
                    
                case let .rewardReady(rewardName, rewardValue):
                    let name = rewardName.isEmpty ? "Empty name" : rewardName
                    let value = rewardValue.isEmpty ? "Empty value" : rewardValue
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
                            return load(state)
                            
                        case .showButtonTapped:
                            state.log("Show button tapped")
                            state.showAfterLoad = false
                            if state.enableFeedbacks {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            return .merge(
                                .cancel(id: NewAdCancel.show(state.adManager.id)),
                                .publisher {
                                    state
                                        .adManager
                                        .events
                                        .receive(on: DispatchQueue.main)
                                        .map { [state] event in
                                            state.log(event: event)
                                            return event.newAction
                                        }
                                }.cancellable(id: NewAdCancel.show(state.adManager.id)),
                                .run { [state] send in
                                    state.adManager.show()
                                }.cancellable(id: NewAdCancel.show(state.adManager.id))
                            )
                            
                        case .loadAndShowButtonTapped:
                            state.log("Load & Show button tapped")
                            state.showAfterLoad = true
                            if state.enableFeedbacks {
                                UIImpactFeedbackGenerator().impactOccurred()
                            }
                            return load(state)
                            
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
                    
                case .bannerAction:
                    state.adManager.close()
                    return .none
                    
                case let .error(error):
                    state.log("Error received \(error.localizedDescription)")
                    state.error = error
                    state.adStateEvent = .adDidFail(error)
                    return .none
                    
                case let .showCampaignId(value):
                    state.adManager.cardConfiguration.showCampaignId = value
                    // if the field is hidden, we "nil" it out
#warning("CHECK THAT FIELD IS NIL WHEN HIDDEN")
//                    if value {
//                        state.baseOptions.campaignId = ""
//                    }
                    return .none
                    
                case let .showCreativeId(value):
                    state.adManager.cardConfiguration.showCreativeId = value
                    // if the field is hidden, we "nil" it out
#warning("CHECK THAT FIELD IS NIL WHEN HIDDEN")
//                    if value {
//                        state.baseOptions.creativeId = ""
//                    }
                    return .none
                    
                case let .showDspFields(value):
                    state.adManager.cardConfiguration.showDspFields = value
                    // if the field is hidden, we "nil" it out
#warning("CHECK THAT FIELD IS NIL WHEN HIDDEN")
//                    if value {
//                        state.baseOptions.dspCreativeId = ""
//                    }
                    return .none
                    
                case let .enableBulkMode(value):
                    state.adManager.cardConfiguration.bulkModeEnabled = value
                    return .none
                    
                    // test mode
                case let .showTestModeButton(show):
                    state.adManager.cardConfiguration.showTestModeButton = show
                    return .none
                    
                case .checkForTestMode:
                    let update = state.updateTestMode()
                    return .none
                    
                case .oguryTestModeButtonTapped:
                    state.log("Ogury test mode button tapped")
                    state.toggleTestMode()
                    return .send(.checkForTestMode)
                    
                case .rtbTestModeButtonTapped:
                    state.log("RTBTest mode button tapped")
                    state.rtbTestModeEnabled.toggle()
                    state.updateRTBTag()
                    state.adManager.cardConfiguration.rtbTestModeEnabled = state.rtbTestModeEnabled
                    return .none
                    
                case let .forceTestMode(enable):
                    state.forceTestMode(enable)
                    return .send(.checkForTestMode)
                    
                case let .enableFeedbacks(enable):
                    state.enableFeedbacks = enable
                    return .none
                    
                case let .enableAdUnitEditing(value):
                    state.adManager.cardConfiguration.enableAdUnitEditing = value
                    return .none
                    
                case .showQALabelTapped:
                    state.adManager.adDelegate?.focusLogs(on: state.adManager.cardConfiguration.qaLabel)
                    return .none
                    
                case .killWebview:
                    state.adManager.killWebview(state.adManager.cardConfiguration.killWebviewMode)
                    return .none
                    
                case let .updateKillMode(mode):
                    state.adManager.cardConfiguration.killWebviewMode = mode
                    return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension AdLifeCycleEvent {
    var newAction: AdViewFeature.Action {
        switch self {
            case let .adDidFailToLoad(error): return .error(error)
            case let .adDidFailToDisplay(error): return .error(error)
            case let .adDidFail(error): return .error(error)
            case let .bannerReady(ad): return .bannerReady(ad)
            case let .rewardReady(rewardName, rewardValue): return .rewardReady(name: rewardName, value: rewardValue)
            default: return .updateEvent(self)
        }
    }
}

extension AdViewFeature.State {
    //MARK: Dynamic accessors
    var cardName: String {
        get { adManager.cardConfiguration.adDisplayName }
        set { adManager.cardConfiguration.adDisplayName = newValue }
    }
    var qaLabel: String {
        get { adManager.cardConfiguration.qaLabel }
        set { adManager.cardConfiguration.qaLabel = newValue }
    }
    var adUnitId: String {
        get { adManager.adConfiguration.adUnitId }
        set { adManager.adConfiguration.adUnitId = newValue }
    }
    var campaignId: String {
        get { adManager.adConfiguration.campaignId ?? "" }
        set { adManager.adConfiguration.campaignId = newValue.isEmpty ? nil : newValue }
    }
    var creativeId: String {
        get { adManager.adConfiguration.creativeId ?? "" }
        set { adManager.adConfiguration.creativeId = newValue.isEmpty ? nil : newValue }
    }
    var dspCreativeId: String {
        get { adManager.adConfiguration.dspCreativeId ?? "" }
        set { adManager.adConfiguration.dspCreativeId = newValue.isEmpty ? nil : newValue }
    }
    var dspRegion: DspRegion? {
        get { adManager.adConfiguration.dspRegion }
        set { adManager.adConfiguration.dspRegion = newValue }
    }
    var showTestModeButton: Bool {
        get { adManager.cardConfiguration.showTestModeButton }
        set { adManager.cardConfiguration.showTestModeButton = newValue }
    }
    var testModeEnabled: Bool {
        get { adManager.cardConfiguration.oguryTestModeEnabled }
        set { adManager.cardConfiguration.oguryTestModeEnabled = newValue }
    }
    var rtbTestModeEnabled: Bool {
        get { adManager.cardConfiguration.rtbTestModeEnabled }
        set { adManager.cardConfiguration.rtbTestModeEnabled = newValue }
    }
    var showRtbTestMode: Bool {
        get { adManager.cardConfiguration.showRtbTestMode }
        set { adManager.cardConfiguration.showRtbTestMode = newValue }
    }
    var enableAdUnitEditing: Bool {
        get { adManager.cardConfiguration.enableAdUnitEditing }
        set { adManager.cardConfiguration.enableAdUnitEditing = newValue }
    }
    var showCampaignId: Bool {
        get { adManager.cardConfiguration.showCampaignId }
        set { adManager.cardConfiguration.showCampaignId = newValue }
    }
    var showCreativeId: Bool {
        get { adManager.cardConfiguration.showCreativeId }
        set { adManager.cardConfiguration.showCreativeId = newValue }
    }
    var showDspFields: Bool {
        get { adManager.cardConfiguration.showDspFields }
        set { adManager.cardConfiguration.showDspFields = newValue }
    }
    var isBanner: Bool { adManager.adFormat.isBanner }
    var isRewardedVideo: Bool { adManager.adFormat == .rewardedVideo }
}

struct BannerContainer: Equatable {
    var bannerAd: UIView?
    var bannerType: AdFormat
}

public extension OguryLogType {
    static let testApp: OguryLogType = .init("TestApp")
    static let receivedCallbacks: OguryLogType = .init("ReceivedCallbacks")
}

extension Error {
    var displayMessage: String {
        if let adError = self as? OguryAdError {
            return "#\(adError.code) : \(adError.localizedDescription)"
        }
        return String(describing: self)
    }
}
