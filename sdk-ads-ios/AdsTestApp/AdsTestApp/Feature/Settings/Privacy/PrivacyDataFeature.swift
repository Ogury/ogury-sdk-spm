//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import ComposableArchitecture
import OguryCore.Private

@Reducer
struct PrivacyDataFeature {
    enum PrivacyData: Equatable, CaseIterable {
        case gpp, gppSID, tcf, usOptout, usOptoutPartner
        var title: String {
            switch self {
                case .gpp: return "GPP"
                case .gppSID: return "GPP SID"
                case .tcf: return "TCF"
                case .usOptout: return "US OPTOUT"
                case .usOptoutPartner: return "US OPTOUT PARTNER"
            }
        }
        var value: String? {
            switch self {
                case .gpp: return OGCInternal.shared().gppConsentString()
                case .gppSID: return OGCInternal.shared().gppSID()
                case .tcf: return OGCInternal.shared().tcfConsentString()
                case .usOptout: return SettingsContainer().usOptout ? "true" : "false"
                case .usOptoutPartner: return SettingsContainer().usOptoutPartner ? "true" : "false"
            }
        }
        var canCopy: Bool {
            switch self {
                case .usOptout, .usOptoutPartner: return false
                default: return true
            }
        }
    }
    @ObservableState
    struct State: Equatable {
        var data: [PrivacyData] = PrivacyData.allCases
    }
    
    enum Action: Equatable  {
        case saveToClipboard(_: String?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case let .saveToClipboard(text):
                    guard let text else { return .none }
                    UIPasteboard.general.string = text
                    return .none
            }
        }
    }
}
