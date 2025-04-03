//
//  MrecPlaceholder.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
internal import ComposableArchitecture

struct BannerPlaceholderView: View {
    let store: StoreOf<BannerPlaceholderFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Text("Creative")
                        .font(.adsTitle2)
                        .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .padding(.leading, 12)
                    
                    if viewStore.bannerAd != nil {
                        Spacer()
                        Button {
                            viewStore.send(.closeButtonTapped)
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(Color(AdColorPalette.Primary.accent.color))
                        }
                        .padding(.trailing, 20)
                    }
                }
                
                // Show AdBannerView centered
                if let ad = viewStore.bannerAd {
                    HStack {
                        Spacer()
                        AdBannerView(banner: ad) // Centered without GeometryReader
                            .frame(width: viewStore.isMrec ? 300 : 320,
                                   height: viewStore.isMrec ? 250 : 50)
                        Spacer()
                    }
                } else {
                    // Use GeometryReader for Placeholder
                    GeometryReader { geometry in
                        let maxWidth = min(geometry.size.width, viewStore.isMrec ? 300 : 320)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(AdColorPalette.Background.secondary.color))
                            
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                Text("Once loaded the creative will be displayed here")
                                    .font(.adsBody)
                                    .minimumScaleFactor(0.6)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, viewStore.isMrec ? 40 : 20)
                            }
                            .foregroundColor(Color(AdColorPalette.Text.placeholder.color))
                            .font(.system(size: viewStore.isMrec ? 14 : 12))
                            .padding(.vertical, 4)
                        }
                        .frame(width: maxWidth)
                        .aspectRatio(ratio(from: viewStore), contentMode: .fit)
                        .frame(width: geometry.size.width, alignment: .center) // Center horizontally
                    }
                    .frame(height: viewStore.isMrec ? 250 : 50) // Ensure fixed height
                }
            }
            .fixedSize(horizontal: false, vertical: true) // Prevent vertical overflow
            .padding(.vertical)
            .frame(maxWidth: .infinity) // Allow horizontal expansion
        }
    }
    
    func ratio(from store: ViewStoreOf<BannerPlaceholderFeature>) -> CGFloat {
        store.isMrec ? (250 / 300) : (50 / 320)
    }
}

struct BannerPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        BannerPlaceholderView(store: Store(
            initialState: BannerPlaceholderFeature.State(bannerType: .smallBanner),
            reducer: { BannerPlaceholderFeature() }))
    }
}
