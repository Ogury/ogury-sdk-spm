//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import SwiftUI

public extension Font {
    // section title
    static var adsLargeTitle: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 26)
        return .custom("PPTelegraf-Semibold", size: scaledSize)
    }
    // section title
    static var adsTitle: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 22)
        return .custom("PPTelegraf-Semibold", size: scaledSize)
    }
    // card title
    static var adsTitle2: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 18)
        return .custom("PPTelegraf-Semibold", size: scaledSize)
    }
    // add format title
    static var adsSubheadline: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 18)
        return .custom("PPTelegraf-Regular", size: scaledSize)
    }
    // add format title
    static var adsHheadline: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 24)
        return .custom("PPTelegraf-Regular", size: scaledSize)
    }
    // textfields, buttons
    static var adsTitle3: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 14)
        return .custom("PPTelegraf-Semibold", size: scaledSize)
    }
    // textfields, buttons
    static var adsBody: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 16)
        return .custom("PPTelegraf-Regular", size: scaledSize)
    }
    // textfields, buttons
    static var adsCaption: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 12)
        return .custom("PPTelegraf-Regular", size: scaledSize)
    }
    // textfields, buttons
    static var adsCaptionSmall: Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: 9)
        return .custom("PPTelegraf-Regular", size: scaledSize)
    }
}

// needed since we load font from a framework...
public class FontLoader {
    static public func loadFont() {
        ["PPTelegraf-Semibold",
         "PPTelegraf-Regular",
         "PPTelegraf-Light",
         "PPTelegraf-Bold",
         "PPTelegraf-Medium"].forEach { font in
            if let fontUrl = Bundle(for: FontLoader.self).url(forResource: font, withExtension: "ttf"),
               let dataProvider = CGDataProvider(url: fontUrl as CFURL),
               let newFont = CGFont(dataProvider) {
                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(newFont, &error)
                {
                    print("Error loading Font!")
                } else {
                    print("Loaded font")
                }
            } else {
                assertionFailure("Error loading font")
            }
        }
    }
}
