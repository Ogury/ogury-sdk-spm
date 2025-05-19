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
    @State private var isShow = false
    
    
    fileprivate func placeholderBanner(viewStore store: ViewStoreOf<BannerPlaceholderFeature>) -> some View {
        GeometryReader { geometry in
            let maxWidth = min(geometry.size.width, store.isMrec ? 300 : 320)
            
            ZStack {
                Rectangle()
                    .fill(Color(AdColorPalette.Background.tertiary.color))
                
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                    Text("Once loaded the creative will be displayed here")
                        .font(.adsBody)
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, store.isMrec ? 40 : 20)
                }
                .foregroundColor(Color(AdColorPalette.Text.placeholder.color))
                .font(.system(size: store.isMrec ? 14 : 12))
                .padding(.vertical, 4)
            }
            .frame(width: maxWidth)
            .aspectRatio(ratio(viewStore: store), contentMode: .fit)
            .frame(width: geometry.size.width, alignment: .center)
        }
        .frame(height: store.isMrec ? 250 : 50)
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { store in
            VStack(alignment: .leading) {
                HStack {
                    Text("Creative")
                        .font(.adsTitle2)
                        .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .padding(.leading, 12)
                    
                    if store.bannerAd != nil {
                        Spacer()
                        Button {
                            store.send(.closeButtonTapped)
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(Color(AdColorPalette.Primary.accent.color))
                        }
                        .padding(.trailing, 20)
                    }
                }
                
                // Show AdBannerView centered
                if let ad = store.bannerAd {
                    HStack(alignment: .center) {
                        if isShow {
                            Spacer()
                            AdBannerView(banner: ad)
                                .frame(height: store.isMrec ? 250 : 50)
                            Spacer()
                        } else {
                            placeholderBanner(viewStore: store)
                        }
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isShow = true
                        }
                    }
                } else {
                    placeholderBanner(viewStore: store)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical)
        }
    }
    
    
    func ratio(viewStore store: ViewStoreOf<BannerPlaceholderFeature>) -> CGFloat {
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
