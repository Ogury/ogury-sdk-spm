//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import OguryAds

final class BannerAdControllerStore {

    // MARK: - Constants

    static let shared = BannerAdControllerStore()

    // MARK: - Properties

    private(set) var controllers = [BannerAdController]()
    private var maxIdOfBanner = 10

    // MARK: - Initialization

    private init() {

    }

    // MARK: - Functions

    static func getInstance(identifier: Int) -> BannerAdController? {
        return instances[identifier]
    }

    func createBannerAdController() -> Int {
        let identifier = getUniqueID()
        instances[identifier] = BannerAdController(identifier: identifier)
        return identifier
    }

    private func getUniqueIdentifier() -> UUID {
        if controllers.count >= maxIdOfBanner - 1 {
            maxIdOfBanner *= 10
        }

        return getUniqueID(withMax: maxIdOfBanner)
    }

    private func getUniqueID(withMax: Int) -> Int {
        var uniqueInt = Int.random(in: 1..<withMax)

        while controllers[uniqueInt] != nil {
            uniqueInt = Int.random(in: 1..<withMax)
        }

        return uniqueInt
    }
}
