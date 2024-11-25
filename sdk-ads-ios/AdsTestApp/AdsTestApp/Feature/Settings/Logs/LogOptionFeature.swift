//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import UIKit
import SwiftUI
import ComposableArchitecture
import AdsCardLibrary
import OguryAds.Private

@Reducer
struct LogOptionFeature {
    @ObservableState
    struct State: Equatable {
        var displayOptions: [OguryLogDisplay] = []
        var allowedTypes: [OguryLogType] = []
        var showColorPicker: Bool = false
        var color: Color = .black
        var selectedType: OguryLogType?
        
        // display options
        var logDisplayDateEnabled: Bool { displayOptions.contains(.date) }
        var logDisplaySDKEnabled: Bool { displayOptions.contains(.SDK) }
        var logDisplayLevelEnabled: Bool { displayOptions.contains(.level) }
        var logDisplayTypeEnabled: Bool { displayOptions.contains(.type) }
        var logDisplayOriginEnabled: Bool { displayOptions.contains(.origin) }
        var logDisplayTagsEnabled: Bool { displayOptions.contains(.tags) }
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
    }
    
    enum Action: Equatable  {
        case logDisplayDateButtonTapped
        case logDisplaySDKButtonTapped
        case logDisplayLevelButtonTapped
        case logDisplayTypeButtonTapped
        case logDisplayOriginButtonTapped
        case logDisplayTagsButtonTapped
        
        case logTypeInternalButtonTapped
        case logTypeRequestButtonTapped
        case logTypePublisherButtonTapped
        case logTypeMraidButtonTapped
        case logTypeMonitoringButtonTapped
        case logTypeDelegateButtonTapped
        
        case selectColor(_: Color)
        case selectPickerForLogType(_: OguryLogType)
        case showColorPicker
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .logDisplayDateButtonTapped:
                    state.toggle(.date)
                    return .none
                    
                case .logDisplaySDKButtonTapped:
                    state.toggle(.SDK)
                    return .none
                    
                case .logDisplayLevelButtonTapped:
                    state.toggle(.level)
                    return .none
                    
                case .logDisplayTypeButtonTapped:
                    state.toggle(.type)
                    return .none
                    
                case .logDisplayOriginButtonTapped:
                    state.toggle(.origin)
                    return .none
                    
                case .logDisplayTagsButtonTapped:
                    state.toggle(.tags)
                    return .none
                    
                case .logTypeInternalButtonTapped:
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
                    
            }
        }
    }
}

