//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import SwiftUI
import ComposableArchitecture
import AdsCardLibrary
import OguryAds.Private

extension OguryLogType: @retroactive CaseIterable {
    public static var allCases: [OguryLogType] = [
        .internal,
        .publisher,
        .delegate,
        .receivedCallbacks,
        .monitoring,
        .mraid,
        .requests,
        .testApp
    ]
}

extension OguryLogDisplay: @retroactive CaseIterable {
    public static var allCases: [OguryLogDisplay] = [
        .SDK,
        .date,
        .level,
        .type,
        .origin,
        .tags
    ]
    var displayName: String {
        switch self {
            case .SDK: return "Show SDK"
            case .date: return "Show date"
            case .level: return "Show log level"
            case .type: return "Show log type"
            case .origin: return "Show origin"
            case .tags: return "show tags"
            default: return ""
        }
    }
}

@Reducer
struct LogOptionFeature {
    @ObservableState
    struct State: Equatable {
        var displayOptions: [OguryLogDisplay] = []
        var allowedTypes: [OguryLogType] = []
        var showColorPicker: Bool = false
        var color: Color = .black
        var selectedType: OguryLogType?
        // Logtypes
        var logTypeInternalEnabled: Bool { allowedTypes.contains(.internal) }
        var logTypeRequestEnabled: Bool { allowedTypes.contains(.requests) }
        var logTypePublisherEnabled: Bool { allowedTypes.contains(.publisher) }
        var logTypeMraidEnabled: Bool { allowedTypes.contains(.mraid) }
        var logTypeMonitoringEnabled: Bool { allowedTypes.contains(.monitoring) }
        var logTypeDelegateEnabled: Bool { allowedTypes.contains(.delegate) }
        // colors
        var logTypeInternalColor: Color {
            get { Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.internal]!) }
            set { (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.internal] = UIColor(newValue) }
        }
        var logTypeRequestColor: Color {
            get { Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.requests]!) }
            set { (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.requests] = UIColor(newValue) }
        }
        var logTypePublisherColor: Color {
            get { Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.publisher]!) }
            set { (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.publisher] = UIColor(newValue) }
        }
        var logTypeMraidColor: Color {
            get { Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.mraid]!) }
            set { (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.mraid] = UIColor(newValue) }
        }
        var logTypeMonitoringColor: Color {
            get { Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.monitoring]!) }
            set { (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.monitoring] = UIColor(newValue) }
        }
        var logTypeDelegateColor: Color {
            get { Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.delegate]!) }
            set { (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[.delegate] = UIColor(newValue) }
        }
        
        init() {
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.SDK.rawValue) != 0) {
                displayOptions.append(.SDK)
            }
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.date.rawValue) != 0) {
                displayOptions.append(.date)
            }
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.origin.rawValue) != 0) {
                displayOptions.append(.origin)
            }
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.tags.rawValue) != 0) {
                displayOptions.append(.tags)
            }
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.level.rawValue) != 0) {
                displayOptions.append(.level)
            }
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.type.rawValue) != 0) {
                displayOptions.append(.type)
            }
            if ((TestAppLogController.shared.logger.logFormatter.displayOptions.rawValue & OguryLogDisplay.type.rawValue) != 0) {
                displayOptions.append(.type)
            }
            TestAppLogController.shared.logger.allowedLogTypes.forEach { logType in
                allowedTypes.append(logType)
            }
        }
        
        mutating func toggle(_ option: OguryLogDisplay) {
            if displayOptions.contains(option) {
                displayOptions.removeAll(where: { $0 == option })
                TestAppLogController.shared.logger.logFormatter.remove(option)
            } else {
                displayOptions.append(option)
                TestAppLogController.shared.logger.logFormatter.add(option)
            }
        }
        
        mutating func toggle(_ type: OguryLogType) {
            if allowedTypes.contains(type) {
                allowedTypes.removeAll(where: { $0 == type })
                TestAppLogController.shared.logger.allowedLogTypes.removeAll(where: { $0 == type })
            } else {
                allowedTypes.append(type)
                TestAppLogController.shared.logger.allowedLogTypes.append(type)
            }
        }
        
        func state(for logDisplay: OguryLogDisplay) -> Bool {
            return displayOptions.contains(logDisplay)
        }
    }
    
    enum Action: Equatable  {
        case logDisplayButtonTapped(_: OguryLogDisplay)
        
        case logTypeInternalButtonTapped
        case logTypeRequestButtonTapped
        case logTypePublisherButtonTapped
        case logTypeMraidButtonTapped
        case logTypeMonitoringButtonTapped
        case logTypeDelegateButtonTapped
        case logTypeButtonTapped(_: OguryLogType)
        
        case selectColor(_: Color)
        case selectPickerForLogType(_: OguryLogType)
        case showColorPicker
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {case .logTypeInternalButtonTapped:
                    state.toggle(.internal)
                    return .none
                    
                case .logTypeRequestButtonTapped:
                    state.toggle(.requests)
                    return .none
                    
                case .logTypePublisherButtonTapped:
                    state.toggle(.publisher)
                    return .none
                    
                case .logTypeMraidButtonTapped:
                    state.toggle(.mraid)
                    return .none
                    
                case .logTypeMonitoringButtonTapped:
                    state.toggle(.monitoring)
                    return .none
                    
                case .logTypeDelegateButtonTapped:
                    state.toggle(.delegate)
                    return .none
                    
                case let .selectColor(color):
                    state.color = color
                    if let type = state.selectedType {
                        (TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[type] = UIColor(color)
                    }
                    return .none
                    
                case . showColorPicker:
                    state.showColorPicker = true
                    return .none
                    
                case let .selectPickerForLogType(logType):
                    state.selectedType = logType
                    state.color = Color((TestAppLogController.shared.logger.logFormatter as! TestAppLogFormatter).logTypeColor[logType]!)
                    return .run {
                        await $0(.showColorPicker)
                    }
                    
                case let .logTypeButtonTapped(logType):
                    state.toggle(logType)
                    return .none
                    
                case let .logDisplayButtonTapped(logDisplay):
                    state.toggle(logDisplay)
                    return .none
            }
        }
    }
}

