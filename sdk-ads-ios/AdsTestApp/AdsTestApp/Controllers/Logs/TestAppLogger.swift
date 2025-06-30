//
//  AdsCardLogger.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 24/09/2024.
//

import OguryCore.Private
import UIKit
import Combine
import UserDefault

public class TestAppLogger: NSObject, OguryLogger {    
    public let logs: PassthroughSubject<NSAttributedString, Never> = PassthroughSubject<NSAttributedString, Never>()
    public var logLevel: OguryLogLevel = .all
    
    @UserDefault("TestAppAllowedLogTypes")
    public var allowedLogTypes: [OguryLogType] = [.publisher, .internal]
    public var logFormatter: OguryLogFormatter = TestAppLogFormatter()
    
    public func logMessage(_ message: OguryLogMessage) {
        guard allowedLogTypes.contains(message.logType as OguryLogType),
        let attr = logFormatter.formatAttributedLogMessage(message) else {
            return
        }
        print("💡 logMessage \(message.message)")
        logs.send(attr)
    }
}

extension OguryLogType: @retroactive DefaultsValueConvertible {
    
}
