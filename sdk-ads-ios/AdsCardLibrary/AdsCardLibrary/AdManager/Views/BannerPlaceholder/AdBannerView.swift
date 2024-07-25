//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import SwiftUI
import OguryAds

struct AdBannerView: UIViewRepresentable {
    let banner: OguryBannerAd
    
    init(banner: OguryBannerAd) { self.banner = banner }
    func makeUIView(context: Context) -> some UIView { return banner }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
