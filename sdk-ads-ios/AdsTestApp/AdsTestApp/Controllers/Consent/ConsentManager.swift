//
//  Copyright © 2020-present Ogury. All rights reserved.
//

import Foundation
import InMobiCMP
import UserMessagingPlatform
import AppTrackingTransparency
import OguryChoiceManager
import SwiftMessages

final class ConsentManager: ChoiceCmpDelegate {

    // MARK: - Initialization
    static let shared = ConsentManager()
    private init() {
       ChoiceCmp.shared.startChoice(pcode: "f2N9N2QnAYZz8", delegate: self)
    }

    // MARK: - Function

    func resetConsent(viewController: UIViewController) {
       ChoiceCmp.shared.forceDisplayUI()
    }
   
    func cmpDidLoad(info: InMobiCMP.PingResponse) {
    }
   
    func cmpDidShow(info: InMobiCMP.PingResponse) {
    }
   
    func didReceiveIABVendorConsent(gdprData: InMobiCMP.GDPRData, updated: Bool) {
    }
   
    func didReceiveNonIABVendorConsent(nonIabData: InMobiCMP.NonIABData, updated: Bool) {
    }
   
    func didReceiveAdditionalConsent(acData: InMobiCMP.ACData, updated: Bool) {
    }
   
    @MainActor func cmpDidError(error: any Error) {
      let view = MessageView.viewFromNib(layout: .cardView)
      view.configureTheme(.error)
      view.configureDropShadow()
      view.configureContent(title: "Error", body: error.reflectedString, iconText: "🙄")
      view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
      (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
      SwiftMessages.show(view: view)
    }
   
    func didReceiveUSRegulationsConsent(usRegData: InMobiCMP.USRegulationsData) {
    }
   
    func userDidMoveToOtherState() {
    }
   
}
