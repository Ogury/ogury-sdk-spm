//
//  TestAppLogger.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 25/09/2024.
//

import Foundation
import AdsCardLibrary
import OguryAds.Private

struct TestAppLogger {
    var adsCardLogger: AdsCardLogger?
    
    init() {
        addLogger()
    }
    
    mutating func addLogger() {
        guard adsCardLogger == nil else { return }
        adsCardLogger = .init()
        OGAInternal.shared().add(adsCardLogger!)
    }
    
    mutating func removeLogger() {
        guard let adsCardLogger else { return }
        OGAInternal.shared().remove(adsCardLogger)
        self.adsCardLogger = nil
    }
    
    func enable(_ option: OguryLogDisplay) {
        guard let adsCardLogger else { return }
        (adsCardLogger.logFormatter as? AdsCardLogFormatter)?.displayOptions.insert(option)
    }
    
    func disable(_ option: OguryLogDisplay) {
        guard let adsCardLogger else { return }
        (adsCardLogger.logFormatter as? AdsCardLogFormatter)?.displayOptions.remove(option)
    }
    
    func enable(_ logType: OguryLogType) {
        guard let adsCardLogger else { return }
        adsCardLogger.allowedLogTypes.append(logType)
    }
    
    func disable(_ logType: OguryLogType) {
        guard let adsCardLogger else { return }
        adsCardLogger.allowedLogTypes.removeAll(where: { $0 == logType })
    }
}
