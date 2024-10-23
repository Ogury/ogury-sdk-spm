//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
