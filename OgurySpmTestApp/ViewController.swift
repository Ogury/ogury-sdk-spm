//
//  ViewController.swift
//  SpmTestApp
//
//  Created by Jerome TONNELIER on 23/06/2025.
//

import UIKit
import OgurySdk
import OguryAds

class ViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!  {
        didSet {
            errorLabel.isHidden = true
            errorLabel.numberOfLines = 0
        }
    }

    @IBOutlet weak var sdkStateButton: UIButton!
    @IBOutlet weak var sdkStateLabel: UILabel!  {
        didSet {
            sdkStateLabel.text = "SDK not started"
        }
    }

    @IBOutlet weak var interLabel: UILabel!  {
        didSet {
            interLabel.text = "Interstitial ad"
        }
    }

    @IBOutlet weak var interLoadButton: UIButton!
    @IBOutlet weak var interShowButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!  {
        didSet {
            loader.isHidden = true
            loader.hidesWhenStopped = true
        }
    }
    
    enum SdkState: Equatable {
        case idle, starting, started, error(_: Error)
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
                case (.idle, .idle): return true
                case (.starting, .starting): return true
                case (.started, .started): return true
                case (.error, .error): return true
                default: return false
            }
        }
    }
    var sdkState: SdkState = .idle  {
        didSet {
            DispatchQueue.main.async {
                self.loader.isHidden = self.sdkState != .starting
                self.errorLabel.isHidden = [.idle, .starting, .started].contains(self.sdkState)
                
                switch self.sdkState {
                    case .idle:
                        self.sdkStateLabel.text = "SdK not started"
                        
                    case .starting:
                        self.sdkStateLabel.text = "SDK starting"
                        self.loader.startAnimating()
                        
                    case .started:
                        self.sdkStateLabel.text = "SDK started"
                        
                    case let .error(error):
                        self.errorLabel.text = error.localizedDescription
                        self.sdkStateLabel.text = "SDK error"
                }
            }
        }
    }
    
    enum AdState: Equatable {
        case idle, loading, loaded, showing, closed, error
    }
    var adState: AdState = .idle {
        didSet {
            switch adState {
                case .idle:
                    interLabel.text = "Interstitial ad"
                    
                case .loading:
                    interLabel.text = "⏱️ Interstitial ad"
                    errorLabel.text = ""
                    loader.startAnimating()
                    
                case .loaded:
                    interLabel.text = "✅ Interstitial ad"
                    loader.stopAnimating()
                    
                case .showing:
                    interLabel.text = "🖥️ Interstitial ad"
                    
                case .closed:
                    interLabel.text = "Interstitial ad"
                    
                case .error:
                    interLabel.text = "‼️ Interstitial ad"
            }
        }
    }
    
    enum SdkError: LocalizedError {
        case sdkNotStarted
        var errorDescription: String? {
            "OgurySdk did not start"
        }
    }
    var interAd: OguryInterstitialAd = {
        let ad = OguryInterstitialAd(adUnitId: Constants.interAdUnitId)
        return ad
    }()
    
    @IBAction func startSdk(_ sender: Any) {
        sdkState = .starting
        adState = .idle
        // starting OgurySdk
        Ogury.start(with: Constants.assetKey) { success, error in
            if let error {
                self.sdkState = .error(error)
                return
            }
            guard success else {
                self.sdkState = .error(SdkError.sdkNotStarted)
                return
            }
            self.sdkState = .started
        }
    }
    
    @IBAction func load(_ sender: Any) {
        adState = .loading
        interAd.delegate = self
        interAd.load()
    }
    
    @IBAction func show(_ sender: Any) {
        interAd.show(in: self)
        adState = .showing
    }
    
    @IBAction func requestConsent(_ sender: Any) {
        AdMobConsentManager.shared.resetConsent(viewController: self)
    }
}

extension ViewController: OguryInterstitialAdDelegate {
    func interstitialAdDidLoad(_ interstitialAd: OguryInterstitialAd) {
        adState = .loaded
    }
    
    func interstitialAdDidClick(_ interstitialAd: OguryInterstitialAd) {
        
    }
    
    func interstitialAdDidClose(_ interstitialAd: OguryInterstitialAd) {
        adState = .closed
    }
    
    func interstitialAdDidTriggerImpression(_ interstitialAd: OguryInterstitialAd) {
        
    }
    
    func interstitialAd(_ interstitialAd: OguryInterstitialAd, didFailWithError error: OguryAdError) {
        adState = .error
        sdkState = .error(error)
    }
}
