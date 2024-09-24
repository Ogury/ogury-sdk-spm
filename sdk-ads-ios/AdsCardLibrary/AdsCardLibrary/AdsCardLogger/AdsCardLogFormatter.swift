//
//  AdsCardLogFormatter.swift
//  AdsCardLibrary
//
//  Created by Jerome TONNELIER on 24/09/2024.
//

import OguryAds.Private
import SwiftUI

class AdsCardLogFormatter: OguryLogFormatter {
    var logTypeColor: [OguryLogType: UIColor] = [
        .delegate : #colorLiteral(red: 0.2221891582, green: 0.3856237233, blue: 0.507037878, alpha: 1),
        .internal : #colorLiteral(red: 0.1386456192, green: 0.3152645528, blue: 0.2698381543, alpha: 1),
        .monitoring : #colorLiteral(red: 0.3214766979, green: 0.2459062338, blue: 0.518550992, alpha: 1),
        .mraid : #colorLiteral(red: 0.3766306043, green: 0.754039824, blue: 0.8901714683, alpha: 1),
        .publisher : #colorLiteral(red: 0.8326988816, green: 0.2894239128, blue: 0.3478675783, alpha: 1),
        .requests : #colorLiteral(red: 0.8553102612, green: 0.6779084802, blue: 0, alpha: 1)
    ]
    
    override func attributes(for option: OguryLogDisplay, originalMessage: OguryLogMessage) -> [NSAttributedString.Key : Any]? {
        var attr = super.attributes(for: option, originalMessage: originalMessage) ?? [:]
        if let color = logTypeColor[originalMessage.logType as OguryLogType] {
            attr[.foregroundColor] = color
        }
        return attr
    }
}
