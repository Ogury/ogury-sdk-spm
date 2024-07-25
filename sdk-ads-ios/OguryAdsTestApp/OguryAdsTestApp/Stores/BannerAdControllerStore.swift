//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import OguryAds

final class BannerAdControllerStore: FormatStore {

    // MARK: - Constants

    static let shared = BannerAdControllerStore()

    typealias Controller = BannerAdController

    // MARK: - Properties

    private(set) var controllers = [Controller]()
    private var lastGeneratedIdentifier = 0

    // MARK: - Initialization

    private init() {

    }

    // MARK: - Functions

    func getInstance(for identifier: Int) -> Controller? {
        return controllers.first { $0.identifier == identifier }
    }

    func createInstance() -> Int {
        let identifier = lastGeneratedIdentifier + 1

        controllers.append(Controller(identifier: identifier))

        lastGeneratedIdentifier += 1

        return identifier
    }

    func destroyInstance(for identifier: Int) {
        guard let controller = controllers.first(where: { $0.identifier == identifier }) else {
            return
        }

        controller.destroy()

        controllers.removeAll { $0.identifier == identifier }
    }
}
