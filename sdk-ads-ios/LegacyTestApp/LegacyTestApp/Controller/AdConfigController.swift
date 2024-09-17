//
//  CampaignController.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 17/03/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import Yaml
import RxSwift
import OguryAds

class AdConfigController {
    
    static let savedConfigKey = "savedConfig"
    static let savedAssetKeyKey = "savedAssetKey"
    static let configurationHeaderBiddingURLKey = "headerBiddingURL"

    static var shared = AdConfigController()

    var config: [Yaml: Yaml]?
    var env = Environment.prod
    let disposeBag = DisposeBag()

    init() {
        readConfig()
        setupRx()
    }

    private var adInterConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var adOptInConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var adMpuConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var adSmallBannerConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var adThumbnailConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var headerBiddingInterConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var headerBiddingOptInConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var headerBiddingMpuConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))
    private var headerBiddingSmallBannerConfig = BehaviorSubject(value: AdConfig(adUnitID: "", campaignID: ""))

    func adConfigObservable(for type: AvailableType) -> Observable<AdConfig> {
        switch type {
            case .interstitial: return adInterConfig.asObserver()
            case .rewarded: return adOptInConfig.asObserver()
            case .thumbnail: return adThumbnailConfig.asObserver()
            case .banner(type: .mpu): return adMpuConfig.asObserver()
            case .banner(type: .smallBanner): return adSmallBannerConfig.asObserver()
            case .logs:return adInterConfig.asObserver()
            case .deprecated(let nestedType): return adConfigObservable(for: nestedType)
            case .headerBidding(let nestedType):
                switch nestedType {
                    case .interstitial: return headerBiddingInterConfig.asObservable()
                    case .rewarded: return headerBiddingOptInConfig.asObservable()
                    case .banner(type: .mpu): return headerBiddingMpuConfig.asObservable()
                    case .banner(type: .smallBanner): return headerBiddingSmallBannerConfig.asObservable()
                    default: fatalError()
                }
        }
    }

    func saveConfig(_ config: AdConfig, for type: AvailableType) {
        

        var encodedConfig = UserDefaults.standard.object(forKey: AdConfigController.savedConfigKey) as? Data

        var savedConfig: [String: [String: AdConfig]] = [:]

        if encodedConfig != nil {
            do {
                let jsonDecoder = JSONDecoder()
                savedConfig = try jsonDecoder.decode([String: [String: AdConfig]].self, from: encodedConfig!)
            } catch {
                print("􀇿 􀇿 Error in parsing saved config 􀇿 􀇿")
            }
        }

        if savedConfig[env.configName] == nil {
            savedConfig[env.configName] = [:]
        }
        savedConfig[env.configName]![type.configName] = config

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            encodedConfig = try jsonEncoder.encode(savedConfig)
        } catch {
        }

        UserDefaults.standard.set(encodedConfig, forKey: AdConfigController.savedConfigKey)
    }
    
    func saveAssetKey(_ assetKey: String) {
        var assetKeys = self.assetKeys() ?? [String: String]()
        assetKeys[env.configName] = assetKey
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        let encodedAssetKeys = try? jsonEncoder.encode(assetKeys)
        UserDefaults.standard.set(encodedAssetKeys, forKey: AdConfigController.savedAssetKeyKey)
    }
    
    func assetKeys() -> [String: String]? {
        guard
            let encodedAssetKey = UserDefaults.standard.data(forKey: "savedAssetKey"),
            let savedAssetKey = try? JSONDecoder().decode([String: String].self, from: encodedAssetKey) else {
                return nil
        }
        return savedAssetKey
    }

    func readConfig() {
        guard let path = Bundle.main.path(forResource: "config", ofType: "yaml") else {
            return
        }
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }

        let configYaml = try? Yaml.load(text)
        config = configYaml?.dictionary
    }

    func setupRx() {
        RxSettings.shared.envObservable.subscribe({ [weak self] env in
            guard let env = env.element, let self = self else {
                return
            }
            self.env = env
            self.updateRxConfig()
        }).disposed(by: disposeBag)
    }

    func updateRxConfig() {
        adInterConfig.on(.next((self.adConfig(for: .interstitial)!)))
        adOptInConfig.on(.next(self.adConfig(for: .rewarded)!))
        adMpuConfig.on(.next(self.adConfig(for: .banner(type: .mpu))!))
        adSmallBannerConfig.on(.next(self.adConfig(for: .banner(type: .smallBanner))!))
        adThumbnailConfig.on(.next(self.adConfig(for: .thumbnail)!))
        headerBiddingInterConfig.on(.next((self.adConfig(for: .headerBidding(.interstitial))!)))
        headerBiddingOptInConfig.on(.next(self.adConfig(for: .headerBidding(.rewarded))!))
        headerBiddingMpuConfig.on(.next(self.adConfig(for: .headerBidding(.banner(type: .mpu)))!))
        headerBiddingSmallBannerConfig.on(.next(self.adConfig(for: .headerBidding(.banner(type: .smallBanner)))!))
    }

    func adConfig(for type: AvailableType) -> AdConfig? {
        if let config = savedAdConfig(for: type) {
            return config
        }
        return defaultAdConfig(for: type)
    }

    func savedAdConfig(for type: AvailableType) -> AdConfig? {
        let encodedConfig = UserDefaults.standard.object(forKey: AdConfigController.savedConfigKey) as? Data

        var savedConfig: [String: [String: AdConfig]] = [:]

        if encodedConfig != nil {
            do {
                let jsonDecoder = JSONDecoder()
                savedConfig = try jsonDecoder.decode([String: [String: AdConfig]].self, from: encodedConfig!)
            } catch {
                print("􀇿 􀇿 Error in parsing saved config 􀇿 􀇿")
                return nil
            }
        }

        guard
                let allConfig = savedConfig[env.configName],
                let config = allConfig[type.configName]
                else {
            return nil
        }

        return config
    }
    
    func savedAssetKey() -> String? {
        guard
            let encodedAssetKey = UserDefaults.standard.data(forKey: "savedAssetKey"),
            let savedAssetKey = try? JSONDecoder().decode([String: String].self, from: encodedAssetKey),
            let assetKey = savedAssetKey[env.configName] else {
                return nil
        }
        return assetKey
    }

    func defaultAdConfig(for type: AvailableType) -> AdConfig? {
        guard
                let dictConfig = config,
                let configEnv = dictConfig[Yaml(stringLiteral: env.configName)]?.dictionary,
                let adsConfig = configEnv[Yaml(stringLiteral: type.configName)]?.dictionary,
                let campaign = adsConfig[Yaml(stringLiteral: "campaign")]?.string,
                let adUnit = adsConfig[Yaml(stringLiteral: "adunit")]?.string
                else {
            return AdConfig()
        }
        guard
                let xOffset = adsConfig[Yaml(stringLiteral: "xOffset")]?.int,
                let yOffset = adsConfig[Yaml(stringLiteral: "yOffset")]?.int,
                let height = adsConfig[Yaml(stringLiteral: "height")]?.int,
                let width = adsConfig[Yaml(stringLiteral: "width")]?.int,
                let corner = adsConfig[Yaml(stringLiteral: "corner")]?.int
                else {
            return AdConfig(adUnitID: adUnit, campaignID: campaign)
        }
        return AdConfig(adUnitID: adUnit,
                campaignID: campaign,
                xOffset: xOffset,
                yOffset: yOffset,
                height: height,
                width: width,
                corner: OguryRectCorner(rawValue: corner))
    }

    func updateEnvironment(resetSDK: Bool = true, newServerEnvironment: String? = nil) {
        guard let serverBaseUrl = newServerEnvironment ?? environment(), !serverBaseUrl.isEmpty else {
            fatalError("Server url must not be nil nor empty.")
        }
        ///
        let sel = NSSelectorFromString("changeServerEnvironment:")
        OGAInternal.shared().perform(sel, with: serverBaseUrl)
        // TODO: Add a button to reset the SDK instead
        if resetSDK {
            DispatchQueue.main.async {
                let sel = NSSelectorFromString("resetSDK")
                OGAInternal.shared().perform(sel)

                guard let assetKey = AdConfigController.shared.assetKey(), !assetKey.isEmpty else {
                    fatalError("Asset key must not be nil nor empty.")
                }
                OGAInternal.shared().start(withAssetKey: assetKey) { succes, error in
                    
                }
                OGAInternal.shared().setLogLevel(.all)
            }
        }
    }
    
    

    func assetKey() -> String? {
        guard let assetKey = savedAssetKey() else {
            return defaultAssetKey()
        }
        
        return assetKey
    }
    
    func defaultAssetKey() -> String? {
        guard
                let dictConfig = config,
                let configEnv = dictConfig[Yaml(stringLiteral: env.configName)]?.dictionary,
                let assetKey = configEnv[Yaml(stringLiteral: "assetKey")]?.string else {
            return nil
        }
        return assetKey
    }

    func environment() -> String? {
        guard
                let dictConfig = config,
                let configEnv = dictConfig[Yaml(stringLiteral: env.configName)]?.dictionary,
                let environment = configEnv[Yaml(stringLiteral: "environment")]?.string else {
            return nil
        }
        return environment
    }

    func headerBiddingURL() -> String? {
        guard
            let dictConfig = config,
            let configEnv = dictConfig[Yaml(stringLiteral: env.configName)]?.dictionary,
            let biddingURL = configEnv[Yaml(stringLiteral: Self.configurationHeaderBiddingURLKey)]?.string else {
            return nil
        }

        return biddingURL
    }
}
