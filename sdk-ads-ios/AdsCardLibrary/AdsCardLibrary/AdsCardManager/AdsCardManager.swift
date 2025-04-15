//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import Foundation
import OguryCore.Private
internal import ComposableArchitecture

public extension String {
    static let testAppLogType: String = "TestApp"
    static let receivedCallbacksLogType: String = "ReceivedCallbacks"
    static let testModeSuffix = "_test"
    var isTestModeOn: Bool { String(suffix(5)) == .testModeSuffix }
}

//MARK: - AdsCardManager
public struct AdsCardManager {
    internal static var logger: OguryLogger?
    
    static func log(_ message: String, origin: String, logType: String = .testAppLogType) {
        AdsCardManager.logger?.logMessage(OguryLogMessage(level: .debug,
                                                          logType: OguryLogType(logType),
                                                          origin: origin,
                                                          sdk: OguryLogSDK("Ads"),
                                                          messageDate: nil,
                                                          message: message,
                                                          tags: nil))
    }
    
    public init(logger: OguryLogger? = nil) {
        AdsCardManager.logger = logger
    }
    /// Return a SwiftUI adView Card to handle ad managed inside the `adManager`
    /// - Parameter adManager: the `AdManager` that handle the underlying ad
    /// - Returns: a SwiftUI AdView object that handles all ad lifecycle through its
    public func card(for adManager: inout any AdManager) -> AdView {
        let store: StoreOf<AdViewFeature> = .init(initialState: .init(adManager: &adManager),
                                                  reducer: { AdViewFeature() } )
        return AdView(store: store)
    }
}

public protocol ErrorConvertible {
    var readableError: String? { get }
}
