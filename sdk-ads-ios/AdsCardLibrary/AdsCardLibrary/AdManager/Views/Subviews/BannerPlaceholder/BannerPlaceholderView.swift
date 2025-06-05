//
//  MrecPlaceholder.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
internal import ComposableArchitecture

struct BannerPlaceholderView: View {
    @Perception.Bindable var store: StoreOf<BannerPlaceholderFeature>
    @State private var isShow = false
    
    fileprivate func placeholderBanner() -> some View {
        ZStack {
            Rectangle()
                .fill(Color(AdColorPalette.Background.secondary.color))
            
            VStack(spacing: 8) {
                Image(systemName: "photo")
                Text("Once loaded the creative will be displayed here")
                    .font(.adsBody)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .foregroundColor(Color(AdColorPalette.Text.placeholder.color))
            .font(.system(size: 12))
            .padding(.vertical, 4)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                WithPerceptionTracking {
                    Text("Creative")
                        .font(.adsTitle2)
                        .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .padding(.leading, 12)
                }
                
                WithPerceptionTracking {
                    if !store.availableSizes.isEmpty {
                        Spacer()
                        
                        Picker("", selection: $store.actualSizeId) {
                            ForEach(store.availableSizes) { size in
                                Label {
                                    Text(size.description)
                                } icon: {
                                    size.image
                                }
                                .tag(size.id)
                                .font(.adsBody)
                                .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            }
                        }
                        .font(.adsBody)
                        .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    }
                }
                
                WithPerceptionTracking {
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
            }
            
            // Show AdBannerView centered
            GeometryReader { geometry in
                WithPerceptionTracking {
                    let maxWidth = min(geometry.size.width, store.actualSize.width)
                    let ratio = store.ratio
                    
                    Group {
                        WithPerceptionTracking {
                            if let ad = store.bannerAd {
                                HStack(alignment: .center) {
                                    if isShow {
                                        AdBannerView(banner: ad)
                                            .clipped()
                                    } else {
                                        placeholderBanner()
                                    }
                                }.onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        isShow = true
                                    }
                                }
                            } else {
                                placeholderBanner()
                            }
                        }
                    }
                    .frame(width: maxWidth, height:store.actualSize.height)
                    .aspectRatio(ratio, contentMode: .fit)
                    .frame(width: geometry.size.width, height:270, alignment: .center)
                }
            }
            .frame(height:250)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical)
        }
    }
}
