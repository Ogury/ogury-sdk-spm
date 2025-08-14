//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import UserDefault
import AdsCardLibrary
import SwiftMessages
import AVFoundation
import OguryCore.Private
import AdSupport

struct AppSettingsFeature: Reducer {
    struct State: Equatable {
        static func == (lhs: AppSettingsFeature.State, rhs: AppSettingsFeature.State) -> Bool {
            lhs.settings == rhs.settings &&
            lhs.showCampaignId == rhs.showCampaignId &&
            lhs.showCreativeId == rhs.showCreativeId &&
            lhs.showDspFields == rhs.showDspFields &&
            lhs.bulkModeEnabled == rhs.bulkModeEnabled &&
            lhs.startSDKWithApplication == rhs.startSDKWithApplication &&
            lhs.showTestMode == rhs.showTestMode &&
            lhs.showShowSection == rhs.showShowSection &&
            lhs.usOptout == rhs.usOptout &&
            lhs.usOptoutPartner == rhs.usOptoutPartner &&
            lhs.enableFeedbacks == rhs.enableFeedbacks &&
            lhs.importMethod == rhs.importMethod &&
            lhs.killWebviewMode == rhs.killWebviewMode &&
            lhs.consentManager == rhs.consentManager &&
            lhs.audioMode == rhs.audioMode &&
            lhs.audioCategory == rhs.audioCategory &&
            lhs.numberOfSDKStart == rhs.numberOfSDKStart
        }
        
        @BindingState var settings: SettingsContainer
        var enableFieldsEditing: Bool {
            settings.fieldEditingMask == .allowAll
        }
        var showCampaignId: Bool { settings.showCampaignId }
        var showCreativeId: Bool { settings.showCreativeId  }
        var showDspFields: Bool { settings.showDspFields }
        var bulkModeEnabled: Bool { settings.bulkModeEnabled }
        var importMethod: ImportMethod { settings.importMethod }
        var killWebviewMode: KillWebviewMode { settings.killWebviewMode }
        var cachedKillWebviewMode: KillWebviewMode?
        var startSDKWithApplication: Bool { settings.startSDKWithApplication }
        var consentManager: ConsentManager { settings.consentManager }
        var numberOfSDKStart: Int {
            get {
                settings.numberOfSdkStart
            }
            set {
                settings.numberOfSdkStart = newValue
            }
        }
        var showTestMode: Bool { settings.showTestMode }
        var usOptout: Bool { settings.usOptout }
        var usOptoutPartner: Bool { settings.usOptoutPartner }
        var enableFeedbacks: Bool { settings.enableFeedbacks }
        var showShowSection = true  {
            didSet {
                UserDefaults.standard.setValue(showShowSection, forKey: "showShowSection")
            }
        }
        var audioCategory: AVAudioSession.Category = AVAudioSession.sharedInstance().category
        var audioMode: AVAudioSession.Mode = AVAudioSession.sharedInstance().mode
        var adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)?
        let generator = UINotificationFeedbackGenerator()

        init(settings: SettingsContainer, adDelegate: (AdLifeCycleDelegate & ApplicationDelegate)?) {
            self.settings = settings
            self.showShowSection = UserDefaults.standard.value(forKey: "showShowSection") != nil
            ? UserDefaults.standard.bool(forKey: "showShowSection")
            : true
            self.adDelegate = adDelegate
        }
        var environment: String { Bundle.main.object(forInfoDictionaryKey: "DefaultEnv") as? String ?? "" }
    }
    
    enum Action: BindableAction, Equatable  {
        case binding(BindingAction<State>)
        case startSDKToggleTapped
        case showCampaignToggleTapped
        case enableFieldsEditingToggleTapped
        case showCreativeToggleTapped
        case showDspFieldsToggleTapped
        case showTestModeToggleTapped
        case bulkModeToggleTapped
        case resetAdConfigButtonTapped
        case enabledTestModeButtonTapped
        case disabledTestModeButtonTapped
        case toggleShowShowSection
        case toggleEnableFeedbacks
        case usOptoutTapped
        case usOptoutPartnerTapped
        case showPrivacyDataTapped
        case incrementSDKStart
        case decrementSDKStart
        case consentManagerSelected(_: ConsentManager)
        case audioModeSelected(_: AVAudioSession.Mode)
        case audioCategorySelected(_: AVAudioSession.Category)
        case updateImportMethod(_: ImportMethod)
        case toggleKillWebviewMode
        case updateKillWebviewMode(_: KillWebviewMode)
        case copyIdfaButtonTapped
        case appendFieldEditingMask(_: FieldEditingMask)
        case removeFieldEditingMask(_: FieldEditingMask)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .copyIdfaButtonTapped:
                    let idfa = ASIdentifierManager().advertisingIdentifier.uuidString
                    UIPasteboard.general.string = idfa
                    return .run { _ in
                        await showNotification(message: "IDFA copied to clipboard\n\(idfa)")
                    }
                    
                case .binding:
                    return .none
                    
                case let .appendFieldEditingMask(mask):
                    if mask == .allowAll {
                        state.settings.fieldEditingMask = mask
                    } else {
                        state.settings.fieldEditingMask.insert(mask)
                    }
                    return .none
                    
                case let .removeFieldEditingMask(mask):
                    if mask == .denyAll {
                        state.settings.fieldEditingMask = mask
                    } else {
                        state.settings.fieldEditingMask.remove(mask)
                    }
                    return .none
                    
                case .incrementSDKStart:
                    state.numberOfSDKStart = min(state.numberOfSDKStart + 1, 10)
                    return .none
                    
                case let .updateImportMethod(method):
                    state.settings.importMethod = method
                    return .none
                    
                case .decrementSDKStart:
                    state.numberOfSDKStart = max(state.numberOfSDKStart - 1, 1)
                    return .none
                    
                case .showCampaignToggleTapped:
                    state.settings.showCampaignId.toggle()
                    return .none
                    
                case .showCreativeToggleTapped:
                    state.settings.showCreativeId.toggle()
                    return .none
                    
                case .showDspFieldsToggleTapped:
                    state.settings.showDspFields.toggle()
                    return .none
                    
                case .bulkModeToggleTapped:
                    state.settings.bulkModeEnabled.toggle()
                    return .none
                    
                case .resetAdConfigButtonTapped:
                    SdkLauncher.shared.adapter.resetSdk()
                    return .run { _ in
                        await showNotification(message: "OguryAds has been reset")
                    }
                    
                case .toggleShowShowSection:
                    state.showShowSection.toggle()
                    return .none
                    
                case .startSDKToggleTapped:
                    state.settings.startSDKWithApplication.toggle()
                    return .none
                    
                case .showTestModeToggleTapped:
                    state.settings.showTestMode.toggle()
                    return .none
                    
                case .enableFieldsEditingToggleTapped:
                    if state.settings.fieldEditingMask == .denyAll {
                        state.settings.fieldEditingMask = .allowAll
                    } else {
                        state.settings.fieldEditingMask = .denyAll
                    }
                    return .none
               
                case .usOptoutTapped:
                    state.settings.usOptout.toggle()
                    OGCInternal.shared().setPrivacyData("us_optout", boolean: state.settings.usOptout)
                    return .none
               
                case .usOptoutPartnerTapped:
                    state.settings.usOptoutPartner.toggle()
                    OGCInternal.shared().setPrivacyData("us_optout_partner", boolean: state.settings.usOptoutPartner)
                    return .none
                    
                case .toggleEnableFeedbacks:
                    state.settings.enableFeedbacks.toggle()
                    if state.settings.enableFeedbacks {
                        state.generator.notificationOccurred(.success)
                    }
                    return .none
                    
                case .enabledTestModeButtonTapped:
                    state.adDelegate?.enableTestModeForAllCards(true)
                    return .run { _ in
                        await showNotification(message: "The test mode has been enabled on all cards")
                    }
                    
                case .disabledTestModeButtonTapped:
                    state.adDelegate?.enableTestModeForAllCards(false)
                    return .run { _ in
                        await showNotification(message: "The test mode has been disabled on all cards")
                    }
                    
                case .toggleKillWebviewMode:
                    if case .none = state.killWebviewMode {
                        state.settings.killWebviewMode = state.cachedKillWebviewMode ?? .simulate
                    } else {
                        state.settings.killWebviewMode = .none
                    }
                    return .none
                    
                case let .updateKillWebviewMode(mode):
                    state.settings.killWebviewMode = mode
                    state.cachedKillWebviewMode = mode
                    return .none
                    
                case .showPrivacyDataTapped:
                    return .none
                    
                case let .consentManagerSelected(cmp):
                    state.settings.consentManager = cmp
                    return .none
                    
                case let .audioModeSelected(mode):
                    state.audioMode = mode
                    var success = true
                    do {
                        try AVAudioSession.sharedInstance().setMode(mode)
                    } catch {
                        success = false
                    }
                    return .run { [success] _ in
                        await showNotification(message: success ? "Audio mode has been updated" : "Audio mode update failed")
                    }
                    
                case let .audioCategorySelected(category):
                    state.audioCategory = category
                    var success = true
                    do {
                        try AVAudioSession.sharedInstance().setCategory(category)
                    } catch {
                        success = false
                    }
                    return .run { [success] _ in
                        await showNotification(message: success ? "Audio category has been updated" : "Audio category update failed")
                    }
            }
        }
    }
}

enum NotificationType {
    case `default`, warning
    
    var backgroundColor: UIColor {
        switch self {
            case .default: return AdColorPalette.Background.primary.color
            case .warning: return AdColorPalette.Primary.accent.color
        }
    }
    var textColor: UIColor {
        switch self {
            case .default: return AdColorPalette.Primary.accent.color
            case .warning: return AdColorPalette.Text.primary(onAccent: true).color
        }
    }
    var iconName: String {
        switch self {
            case .default: return "info.circle"
            case .warning: return "exclamationmark.triangle"
        }
    }
}

@MainActor func showNotification(title: String = "We're all set 🎉",
                                 message: String,
                                 duration: SwiftMessages.Duration = .seconds(seconds: 5),
                                 notificationType: NotificationType = .default) {
    let view = MessageView.viewFromNib(layout: .messageView)
    view.configureDropShadow()
    view.configureContent(title: title, body: message, iconImage: UIImage(systemName: "i.circle")!)
    view.iconImageView?.tintColor = notificationType.textColor
    view.iconImageView?.image = UIImage(systemName: notificationType.iconName)
    view.bodyLabel?.textColor = notificationType.textColor
    view.titleLabel?.textColor = notificationType.textColor
    view.backgroundColor = notificationType.backgroundColor
    view.button?.isHidden = true
    var conf: SwiftMessages.Config = .init()
    conf.duration = duration
    SwiftMessages.show(config: conf, view: view)
}

extension AVAudioSession.Category {
    static let allCases: [Self] = { AVAudioSession.sharedInstance().availableCategories }()
    var displayName: String? {
        switch self {
            case .ambient: return "Ambiant"
            case .soloAmbient: return "Solo Ambiant"
            case .multiRoute: return "Multiroute"
            case .playAndRecord: return "Play and Record"
            case .playback: return "Playback"
            case .record: return "Record"
            default: return nil
        }
    }
}

extension AVAudioSession.Mode {
    static let allCases: [Self] = { AVAudioSession.sharedInstance().availableModes }()
    var displayName: String? {
        switch self {
            case .default: return "Default"
            case .gameChat: return "Game chat"
            case .measurement: return "Measurement"
            case .moviePlayback: return "Movie playback"
            case .spokenAudio: return "Spoken audio"
            case .videoChat: return "Video chat"
            case .videoRecording: return "Video recording"
            case .voiceChat: return "Voice chat"
            case .voicePrompt: return "Voice prompt"
            default: return nil
        }
    }
}
