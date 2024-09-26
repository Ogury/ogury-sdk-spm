//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import os.log
import UIKit
import OgurySdk
import OguryAds
import InMobiCMP
import SwiftMessages

class HomeViewController: UIViewController, ChoiceCmpDelegate {
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
   
   func cmpDidError(error: any Error) {
      let view = MessageView.viewFromNib(layout: .cardView)
      view.configureTheme(.error)
      view.configureDropShadow()
      view.configureContent(title: "Error", body: error.localizedDescription, iconText: "🙄")
      view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
      (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
      SwiftMessages.show(view: view)
   }
   
   func didReceiveUSRegulationsConsent(usRegData: InMobiCMP.USRegulationsData) {
      
   }
   
   func userDidMoveToOtherState() {
      
   }
   
    
    @IBOutlet weak var interstitialAdUnitIdText: UITextField!
    let mediation = OguryMediation(name: "WrapperTestApp", version: "1.0.0")
    
    var interstitialAd: OguryInterstitialAd? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load defaults from environment
        interstitialAdUnitIdText.text = getEnvironment().interstitialAdUnitId
       ChoiceCmp.shared.startChoice(pcode: "f2N9N2QnAYZz8", delegate: self)
    }
    
    @IBAction func startButtonClicked() {
        let config = OguryConfigurationBuilder(assetKey: getEnvironment().assetKey)
            .build()
        Ogury.setLogLevel(.all)
        Ogury.start(with: config, completionHandler: { success, error in
            print("success : \(success)")
            if let error = error {
                switch (error.code) {
                case OguryStartErrorCode.failedStartingOguryModule.rawValue :
                    print("\(error.localizedDescription)")
                    break
                case OguryStartErrorCode.noModuleFound.rawValue :
                    print("\(error.localizedDescription)")
                    break
                default:
                    break
                }
            }
            
            
        })
    }
    
    @IBAction func askButtonClicked() {
       ChoiceCmp.shared.forceDisplayUI()
    }
    
    @IBAction func interstitialLoadButtonClicked() {
        guard let adUnitId = interstitialAdUnitIdText.text, !adUnitId.isEmpty else {
            os_log("Interstitial ad unit id must not be empty")
            return
        }
        let interstitialAd = getOrCreateInterstitialAd(adUnitId: adUnitId)
        interstitialAd.load()
    }
    
    @IBAction func interstitialShowButtonClicked() {
        guard let interstitialAd = self.interstitialAd else {
            os_log("Load an interstitial ad before.")
            return
        }
        interstitialAd.show(in: self)
    }
    
    func getOrCreateInterstitialAd(adUnitId: String) -> OguryInterstitialAd {
        if (self.interstitialAd != nil && self.interstitialAd?.adUnitId == adUnitId) {
            return self.interstitialAd!
        }
        let interstitialAd = OguryInterstitialAd(adUnitId: adUnitId, mediation: mediation)
        interstitialAd.delegate = self
        self.interstitialAd = interstitialAd
        return interstitialAd
    }
}

extension HomeViewController : OguryInterstitialAdDelegate {
    
    func didLoad(_ interstitial: OguryInterstitialAd) {
        os_log("Interstitial ad loaded.")
    }
    
    func didFailOguryInterstitialAdWithError(_ error: OguryError, for interstitial: OguryInterstitialAd) {
        os_log("Interstitial ad failed with error: %@", String(describing: error))
    }
    
    func didDisplay(_ interstitial: OguryInterstitialAd) {
        os_log("Interstitial ad displayed.")
    }
    
    func didClick(_ interstitial: OguryInterstitialAd) {
        os_log("Interstitial ad clicked.")
    }
    
    func didClose(_ interstitial: OguryInterstitialAd) {
        os_log("Interstitial ad closed.")
    }
}
