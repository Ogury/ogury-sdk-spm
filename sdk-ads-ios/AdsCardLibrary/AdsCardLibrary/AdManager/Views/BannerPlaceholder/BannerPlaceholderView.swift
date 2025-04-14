//
//  MrecPlaceholder.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
import ComposableArchitecture
import OguryAds

struct BannerPlaceholderView: View {
    let store: StoreOf<BannerPlaceholderFeature>
    @State private var isShow = false
    
    
    fileprivate func placeholderBanner(viewStore: ViewStoreOf<BannerPlaceholderFeature>) -> some View {
        GeometryReader { geometry in
            let maxWidth = min(geometry.size.width, viewStore.isMpuFormat ? 300 : 320)
            
            ZStack {
                Rectangle()
                    .fill(Color(AdColorPalette.Background.tertiary.color))
                
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                    Text("Once loaded the creative will be displayed here")
                        .font(.adsBody)
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, viewStore.isMpuFormat ? 40 : 20)
                }
                .foregroundColor(Color(AdColorPalette.Text.placeholder.color))
                .font(.system(size: viewStore.isMpuFormat ? 14 : 12))
                .padding(.vertical, 4)
            }
            .frame(width: maxWidth)
            .aspectRatio(ratio(from: viewStore), contentMode: .fit)
            .frame(width: geometry.size.width, alignment: .center)
        }
        .frame(height: viewStore.isMpuFormat ? 250 : 50)
    }
    
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
                    HStack(alignment: .center) {
                        if isShow {
                            AdBannerView(banner: ad)
                                .frame(height: viewStore.isMpuFormat ? 250 : 50)
                        } else {
                            placeholderBanner(viewStore: viewStore)
                        }
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isShow = true
                        }
                    }
                } else {
                    placeholderBanner(viewStore: viewStore)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical)
            
        }
        
    }
    
    
    func ratio(from store: ViewStoreOf<BannerPlaceholderFeature>) -> CGFloat {
        store.bannerType == .mpu ? (250 / 300) : (50 / 320)
    }
}

struct BannerPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        BannerPlaceholderView(store: Store(
            initialState: BannerPlaceholderFeature.State(bannerType: .banner),
            reducer: { BannerPlaceholderFeature() }))
    }
}
