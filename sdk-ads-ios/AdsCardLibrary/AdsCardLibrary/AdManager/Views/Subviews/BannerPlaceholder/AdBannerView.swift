//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import SwiftUI

struct AdBannerView: UIViewRepresentable {
    let banner: UIView
    
    init(banner: UIView) { self.banner = banner }
    func makeUIView(context: Context) -> some UIView {
        banner.clipsToBounds = true
        return banner
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
