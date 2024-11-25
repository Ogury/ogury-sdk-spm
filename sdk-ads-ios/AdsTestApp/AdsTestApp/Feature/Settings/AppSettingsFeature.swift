//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import UserDefault
import OguryAds
import AdsCardLibrary
import SwiftMessages
import OguryAds.Private



struct AppSettingsFeature: Reducer {
    struct State: Equatable {
        static func == (lhs: AppSettingsFeature.State, rhs: AppSettingsFeature.State) -> Bool {
            lhs.settings == rhs.settings &&
            lhs.showCampaignId == rhs.showCampaignId &&
            lhs.showCreativeId == rhs.showCreativeId &&
            lhs.showSpecificOptions == rhs.showSpecificOptions &&
            lhs.showDspFields == rhs.showDspFields &&
            lhs.bulkModeEnabled == rhs.bulkModeEnabled &&
            lhs.startSDKWithApplication == rhs.startSDKWithApplication &&
            lhs.showTestMode == rhs.showTestMode &&
            lhs.showShowSection == rhs.showShowSection &&
            lhs.usOptout == rhs.usOptout &&
            lhs.usOptoutPartner == rhs.usOptoutPartner &&
            lhs.enableFeedbacks == rhs.enableFeedbacks &&
            lhs.numberOfSDKStart == rhs.numberOfSDKStart
        }
        
        @BindingState var settings: SettingsContainer
        var enableAdUnitEditing: Bool { settings.enableAdUnitEditing }
        var showCampaignId: Bool { settings.showCampaignId }
        var showCreativeId: Bool { settings.showCreativeId  }
        var showSpecificOptions: Bool { settings.showSpecificOptions }
        var showDspFields: Bool { settings.showDspFields }
        var bulkModeEnabled: Bool { settings.bulkModeEnabled }
        var startSDKWithApplication: Bool { settings.startSDKWithApplication }
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
        var adDelegate: AdLifeCycleDelegate?
        let generator = UINotificationFeedbackGenerator()
        var logOptions: LogOptionFeature.State?

        init(settings: SettingsContainer, adDelegate: AdLifeCycleDelegate?) {
            self.settings = settings
            self.showShowSection = UserDefaults.standard.value(forKey: "showShowSection") != nil
            ? UserDefaults.standard.bool(forKey: "showShowSection")
            : true
            self.adDelegate = adDelegate
        }
        var appVersion: String {
            "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) - build \(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)"
        }
        var sdkVersion: String {
            let origin = Bundle.main.object(forInfoDictionaryKey: "SDK_SOURCE") as? String ?? "Dev"
            return "\(OGAInternal.shared().getVersion()) (\(origin == "Pod" ? "Release" : "Development"))"
        }
        var environment: String { Bundle.main.object(forInfoDictionaryKey: "DefaultEnv") as? String ?? "" }
    }
    
    enum Action: BindableAction, Equatable  {
        case binding(BindingAction<State>)
        case startSDKToggleTapped
        case showCampaignToggleTapped
        case enableAdUnitEditingToggleTapped
        case showSpecificOptionsToggleTapped
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
        case logOptionsButtonTapped
        case logOptions(LogOptionFeature.Action)
        case incrementSDKStart
        case decrementSDKStart
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                    
                case .incrementSDKStart:
                    state.numberOfSDKStart = min(state.numberOfSDKStart + 1, 10)
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
                    
                case .showSpecificOptionsToggleTapped:
                    state.settings.showSpecificOptions.toggle()
                    return .none
                    
                case .resetAdConfigButtonTapped:
                    return .none
                    
                case .toggleShowShowSection:
                    state.showShowSection.toggle()
                    return .none
                    
                case .startSDKToggleTapped:
                    state.settings.startSDKWithApplication.toggle()
                    return .none
                    
                case .showTestModeToggleTapped:
                    state.settings.showTestMode.toggle()
                    return .none
                    
                case .enableAdUnitEditingToggleTapped:
                    state.settings.enableAdUnitEditing.toggle()
                    return .none
               
                case .usOptoutTapped:
                    state.settings.usOptout.toggle()
                    OGCInternal.shared().setPrivacyData("us_optout", boolean: state.settings.usOptout)
                    return .none
               
                case .usOptoutPartnerTapped:
                    state.settings.usOptoutPartner.toggle()
                    OGCInternal.shared().setPrivacyData("us_optout_partner", boolean: state.settings.usOptoutPartner)
                    return .none
               
                case .showPrivacyDataTapped:
                    return .run { _ in
                       await showNotification(title: "Privacy info", message: OGCInternal.shared().retrieveDataPrivacy().description)
                    }
                    
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
                    
                case .logOptionsButtonTapped:
                    state.logOptions = .init()
                    return .none
                    
                case .logOptions:
                    return .none
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
