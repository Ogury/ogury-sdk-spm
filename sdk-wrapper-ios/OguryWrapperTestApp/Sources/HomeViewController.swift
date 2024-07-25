//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import os.log
import UIKit
import OgurySdk
import OguryChoiceManager
import OguryAds

class HomeViewController: UIViewController {
    
    @IBOutlet weak var interstitialAdUnitIdText: UITextField!
    let mediation = OguryMediation(name: "WrapperTestApp", version: "1.0.0")
    
    var interstitialAd: OguryInterstitialAd? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load defaults from environment
        interstitialAdUnitIdText.text = getEnvironment().interstitialAdUnitId
    }
    
    @IBAction func startButtonClicked() {
        let config = OguryConfigurationBuilder(assetKey: getEnvironment().assetKey)
            .build()
        Ogury.start(with: config)
        Ogury.setLogLevel(OguryLogLevel.all)
    }
    
    @IBAction func askButtonClicked() {
        OguryChoiceManager.shared().ask(with: self) { (error, answer) in
            if (error != nil) {
                os_log("Ask failed with error: %@", String(describing: error))
            } else {
                os_log("Ask completed with answer: %d", answer.rawValue)
            }
        }
    }
    
    @IBAction func editButtonClicked() {
        OguryChoiceManager.shared().edit(with: self) { (error, answer) in
            if (error != nil) {
                os_log("Edit failed with error: %@", String(describing: error))
            } else {
                os_log("Edit completed with answer: %d", answer.rawValue)
            }
        }
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
