//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import UIKit
import SwiftUI

public protocol Colorable {
    var color: UIColor { get }
}

public struct AdColorPalette {
    public enum Primary: Colorable {
        case accent
        case accentLight
        case supplementary
        
        public var color: UIColor {
            switch self {
                case .accent: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.4343036024, green: 0.8960282061, blue: 0.9006944444, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0, green: 0.231372549, blue: 0.3882352941, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0, green: 0.4201652408, blue: 0.4244114757, alpha: 1)
                    }
                }
                    
                case .accentLight: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.231372549, blue: 0.3882352941, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.8901960784, green: 0.9294117647, blue: 0.9960784314, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0.8037284613, green: 0.9222920537, blue: 0.5354133844, alpha: 1)
                    }
                }
                    
                case .supplementary: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.4666666667, blue: 0.7803921569, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0, green: 0.4666666667, blue: 0.7803921569, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0, green: 0.3014233708, blue: 0.4644566774, alpha: 1)
                    }
                }
            }
        }
    }
    
    private enum Gradient: Colorable {
        case start
        case end
        public var color: UIColor {
            switch self {
                case .start: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.07413701934, blue: 0.1142361111, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 0.04)
                        @unknown default: return #colorLiteral(red: 0, green: 0.4201652408, blue: 0.4244114757, alpha: 1)
                    }
                }
                case .end: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.07413701934, blue: 0.1142361111, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 0.04)
                        @unknown default: return #colorLiteral(red: 0, green: 0.4201652408, blue: 0.4244114757, alpha: 1)
                    }
                }
            }
        }
    }
    
    public static var primaryGradient: LinearGradient {
        LinearGradient(colors: [Color(AdColorPalette.Gradient.start.color), Color(AdColorPalette.Gradient.end.color)], startPoint: .top, endPoint: .bottom)
    }
    
    public enum Background: Colorable {
        case primary
        case secondary
        case separator
        case placeholder
        case disabled
        case shadow
        
        public var color: UIColor {
            switch self {
                case .primary: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.09707668065, blue: 0.1495833333, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        @unknown default: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                }
                    
                case .secondary: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.03955852202, blue: 0.0609548611, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0.9656843543, green: 0.9657825828, blue: 0.9688259959, alpha: 1)
                    }
                }
                    
                case .separator: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 0.05)
                        case .light, .unspecified: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 0.05)
                        @unknown default: return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.48)
                    }
                }
                    
                case .placeholder: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.6567534722, green: 0.6567534722, blue: 0.6567534722, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.8388590217, green: 0.8388590217, blue: 0.8388590217, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0.8388590217, green: 0.8388590217, blue: 0.8388590217, alpha: 1)
                    }
                }
                    
                case .disabled: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.03955852202, blue: 0.0609548611, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 0.05)
                        @unknown default: return #colorLiteral(red: 0.8388590217, green: 0.8388590217, blue: 0.8388590217, alpha: 1)
                    }
                }
                    
                case .shadow: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0, green: 0.23, blue: 0.39, alpha: 0.2)
                        case .light, .unspecified: return #colorLiteral(red: 0, green: 0.23, blue: 0.39, alpha: 0.05763509825)
                        @unknown default: return #colorLiteral(red: 0, green: 0.23, blue: 0.39, alpha: 0.2)
                    }
                }
            }
        }
    }
    
    public enum State: Colorable {
        case success
        case failure
        case selected
        
        public var color: UIColor {
            switch self {
                case .success: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.1137254902, green: 0.5294117647, blue: 0.3529411765, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.1137254902, green: 0.5294117647, blue: 0.3529411765, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    }
                }
                    
                case .failure: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.7607843137, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.7607843137, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
                        @unknown default: return #colorLiteral(red: 1, green: 0.09617697448, blue: 0, alpha: 1)
                    }
                }
                    
                case .selected: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.207301259, green: 0.4516493678, blue: 0.4202194512, alpha: 1)
                        case .light, .unspecified: return #colorLiteral(red: 0.207301259, green: 0.4516493678, blue: 0.4202194512, alpha: 1)
                        @unknown default: return #colorLiteral(red: 0.207301259, green: 0.4516493678, blue: 0.4202194512, alpha: 1)
                    }
                }
                    
            }
        }
    }
    
    public enum Text: Colorable {
        case primary(onAccent: Bool)
        case secondary(onAccent: Bool)
        case supplementary(onAccent: Bool)
        case placeholder
        
        public var color: UIColor {
            switch self {
                case .primary(let onAccent):
                    switch onAccent {
                        case true: return UIColor { trait in
                            switch trait.userInterfaceStyle {
                                case .dark: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                                case .light, .unspecified: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                                @unknown default: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            }
                        }
                        case false: return UIColor { trait in
                            switch trait.userInterfaceStyle {
                                case .dark: return #colorLiteral(red: 0.4343036024, green: 0.8960282061, blue: 0.9006944444, alpha: 1)
                                case .light, .unspecified: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 1)
                                @unknown default: return #colorLiteral(red: 0.1221465245, green: 0.3132303059, blue: 0.4406013489, alpha: 1)
                            }
                        }
                    }
                    
                case .secondary(let onAccent):
                    switch onAccent {
                        case true: return UIColor { trait in
                            switch trait.userInterfaceStyle {
                                case .dark: return #colorLiteral(red: 0.8388590217, green: 0.8388590217, blue: 0.8388590217, alpha: 1)
                                case .light, .unspecified: return #colorLiteral(red: 0, green: 0.3014233708, blue: 0.4644566774, alpha: 1)
                                @unknown default: return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                            }
                        }
                        case false: return UIColor { trait in
                            switch trait.userInterfaceStyle {
                                case .dark: return #colorLiteral(red: 0.204393192, green: 0.3731693475, blue: 0.4644566774, alpha: 1)
                                case .light, .unspecified: return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 1)
                                @unknown default: return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 1)
                            }
                    }
                }
                    
                case .supplementary(let onAccent):
                    switch onAccent {
                        case true: return UIColor { trait in
                            switch trait.userInterfaceStyle {
                                case .dark: return #colorLiteral(red: 0, green: 0.3014233708, blue: 0.4644566774, alpha: 1)
                                case .light, .unspecified: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                                @unknown default: return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                            }
                        }
                        case false: return UIColor { trait in
                            switch trait.userInterfaceStyle {
                                case .dark: return #colorLiteral(red: 0.6169638937, green: 0.6169638937, blue: 0.6889430146, alpha: 1)
                                case .light, .unspecified: return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 1)
                                @unknown default: return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 1)
                            }
                    }
                }
                    
                case .placeholder: return UIColor { trait in
                    switch trait.userInterfaceStyle {
                        case .dark: return #colorLiteral(red: 0.5722569444, green: 0.5722569444, blue: 0.5722569444, alpha: 0.64)
                        case .light, .unspecified: return #colorLiteral(red: 0.1058823529, green: 0.1921568627, blue: 0.2705882353, alpha: 0.64)
                        @unknown default: return #colorLiteral(red: 0.8388590217, green: 0.8388590217, blue: 0.8388590217, alpha: 1)
                    }
                }
                    
            }
        }
    }
}
