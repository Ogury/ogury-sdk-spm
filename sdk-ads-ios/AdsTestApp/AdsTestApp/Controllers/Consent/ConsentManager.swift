//
//  Copyright © 2020-present Ogury. All rights reserved.
//

import Foundation
import InMobiCMP
import AppTrackingTransparency
import SwiftMessages
import UIKit

final class ConsentManager: ChoiceCmpDelegate {
    
    // MARK: - Initialization
    static let shared = ConsentManager()
    private enum ConsentState {
        case idle, loading, loaded, shown, error
    }
    private var consentState: ConsentState = .idle
    
    // MARK: - Function
    
    func resetConsent(viewController: UIViewController) {
        if consentState == .idle {
            consentState = .loading
            ChoiceCmp.shared.startChoice(pcode: "f2N9N2QnAYZz8", delegate: self)
        } else {
            ChoiceCmp.shared.forceDisplayUI()
        }
    }
    
    func cmpDidLoad(info: InMobiCMP.PingResponse) {
        consentState = .loaded
    }
    
    func cmpDidShow(info: InMobiCMP.PingResponse) {
        consentState = .shown
    }
    
    func didReceiveIABVendorConsent(gdprData: InMobiCMP.GDPRData, updated: Bool) {
    }
    
    func didReceiveNonIABVendorConsent(nonIabData: InMobiCMP.NonIABData, updated: Bool) {
    }
    
    func didReceiveAdditionalConsent(acData: InMobiCMP.ACData, updated: Bool) {
    }
    
    func cmpDidError(error: any Error) {
        consentState = .error
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(title: "Error", body: error.reflectedString, iconText: "⚠️")
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        Task {
            await SwiftMessages.show(view: view)
        }
    }
    
    func didReceiveUSRegulationsConsent(usRegData: InMobiCMP.USRegulationsData) {
    }
    
    func userDidMoveToOtherState() {
    }
    
}
