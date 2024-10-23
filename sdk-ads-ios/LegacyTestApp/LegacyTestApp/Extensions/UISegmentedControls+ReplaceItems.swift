//
//  UISegmentedControls+ReplaceItems.swift
//  OguryAdsTestApp
//
//  Created by Pernic on 22/06/2020.
//  Copyright © 2020 co.ogury. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    func replaceSegments(segments: [String]) {
        removeAllSegments()
        for segment in segments {
            insertSegment(withTitle: segment, at: numberOfSegments, animated: false)
        }
    }
}
