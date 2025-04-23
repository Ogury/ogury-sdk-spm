//
//  TestAppLogger.swift
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 25/09/2024.
//

import Foundation
import AdsCardLibrary
import OguryCore.Private

internal struct TestAppLogController {
    let logger = TestAppLogger()
    static let shared = TestAppLogController()
    private init() {
        addLogger()
    }
    
    mutating func addLogger() {
        SdkLauncher.shared.adapter.add(logger: logger)
    }
    
    func enable(_ option: OguryLogDisplay) {
        (logger.logFormatter as? TestAppLogFormatter)?.displayOptions.insert(option)
    }
    
    func disable(_ option: OguryLogDisplay) {
        (logger.logFormatter as? TestAppLogFormatter)?.displayOptions.remove(option)
    }
    
    func enable(_ logType: OguryLogType) {
        logger.allowedLogTypes.append(logType)
    }
    
    func disable(_ logType: OguryLogType) {
        logger.allowedLogTypes.removeAll(where: { $0 == logType })
    }
}
