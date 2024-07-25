//
//  MrecPlaceholder.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
import ComposableArchitecture

struct BannerPlaceholderView: View {
    let store: StoreOf<BannerPlaceholderFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Text("Creative")
                        .font(.adsTitle2)
                    
                    if viewStore.bannerAd != nil {
                        Spacer()
                        
                        Button {
                            viewStore.send(.closeButtonTapped)
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(Color(AdColorPalette.Primary.accent.color))
                        }
                    }
                }
                
                Group {
                    if let ad = viewStore.bannerAd {
                        AdBannerView(banner: ad)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color(AdColorPalette.Background.secondary.color))
                            
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                
                                Text("Once loaded the creative will be displayed here")
                                    .font(.adsBody)
                                    .multilineTextAlignment(.center)
                                    .padding(EdgeInsets(top: 0,
                                                        leading: viewStore.isMpuFormat ? 40 : 20,
                                                        bottom: 0,
                                                        trailing: viewStore.isMpuFormat ? 40 : 20))
                            }
                            .foregroundColor(Color(AdColorPalette.Text.placeholder.color))
                            .font(.system(size: viewStore.isMpuFormat ? 14 : 12))
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(width: viewStore.isMpuFormat ? 300 : 320,
                       height: viewStore.isMpuFormat ? 250 : 50)
            }
            .fixedSize()
            .padding(.vertical)
            .frame(maxWidth: .infinity)
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
