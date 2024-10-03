//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

import OguryAds

protocol FormatStore {

    associatedtype Controller

    // MARK: - Functions

    func getInstance(for identifier: Int) -> Controller?

    func createInstance() -> Int
}
