//
//  AdsCardLogger.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 24/09/2024.
//

import OguryAds.Private
import UIKit
import Combine

public class AdsCardLogger: NSObject, OguryLogger {
    public let logs: PassthroughSubject<NSAttributedString, Never> = PassthroughSubject<NSAttributedString, Never>()
    public var logLevel: OguryLogLevel = .all
    public var allowedLogTypes: [OguryLogType] = [.all]
    public var logFormatter: OguryLogFormatter = AdsCardLogFormatter()
    
    public func logMessage(_ message: OguryLogMessage) {
        guard let attr = logFormatter.formatAttributedLogMessage(message) else { return }
        logs.send(attr)
    }
}
