//
//  ThumbnailOptionView.swift
//  AdCard
//
//  Created by Jerome TONNELIER on 21/07/2023.
//

import SwiftUI
import ComposableArchitecture

struct ThumbnailOptionView: View {
    let store: StoreOf<ThumbnailOptionFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            if viewStore.options.showOptions {
                VStack(alignment: .leading) {
                    Text("Position and settings")
                        .font(.adsTitle2)
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Thumbnail mode")
                                .font(.adsTitle2)
                                .foregroundColor(Color(AdColorPalette.Text.secondary(onAccent: false).color))
                            
                            Text(" (\(viewStore.options.thumbnailPosition.displayName))")
                                .foregroundColor(Color(AdColorPalette.Text.secondary(onAccent: false).color))
                                .font(.adsBody)
                        }
                        
                        Picker("",
                               selection: viewStore.$options.thumbnailPosition,
                               content: {
                            ForEach(ThumbnailPosition.allCases) { thumb in
                                Image(systemName:thumb.imageName)
                            }
                        })
                        .pickerStyle(.segmented)
                        .accentColor(Color(AdColorPalette.Primary.supplementary.color))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)
                    
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(viewStore.options.thumbnailPosition.sectionName)
                                .font(.adsTitle2)
                                .foregroundColor(viewStore.options.thumbnailPosition.sectionDisabled
                                                 ? Color(AdColorPalette.Text.placeholder.color)
                                                 : Color(AdColorPalette.Text.secondary(onAccent: false).color))
                                .padding(.bottom, 8)
                            
                            HStack {
                                AdsTextField(viewStore.$options.xOffset,
                                             placeholder: "X")
                                .disabled(viewStore.options.thumbnailPosition.sectionDisabled)
                                
                                AdsTextField(viewStore.$options.yOffset,
                                             placeholder: "Y")
                                .disabled(viewStore.options.thumbnailPosition.sectionDisabled)
                            }
                        }
                        .padding()
                        .background(Color(AdColorPalette.Background.disabled.color))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                        
                        VStack(alignment: .leading) {
                            Text(viewStore.options.thumbnailPosition.sectionDisabled ? "Not Applicable" : "Size")
                                .foregroundColor(viewStore.options.thumbnailPosition.sectionDisabled
                                                 ? Color(AdColorPalette.Text.placeholder.color)
                                                 : Color(AdColorPalette.Text.secondary(onAccent: false).color))
                                .font(.adsTitle2)
                                .padding(.bottom, 8)
                            
                            HStack {
                                AdsTextField(viewStore.$options.width,
                                             placeholder: "W")
                                .disabled(viewStore.options.thumbnailPosition.sectionDisabled)
                                
                                AdsTextField(viewStore.$options.height,
                                             placeholder: "H")
                                .disabled(viewStore.options.thumbnailPosition.sectionDisabled)
                            }
                        }
                        .padding()
                        .background(Color(AdColorPalette.Background.disabled.color))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                    }
                    .padding(.top)
                    .transition(.opacity)
                    .disabled(viewStore.options.thumbnailPosition.sectionDisabled)
                }
            }
        }
        .padding()
        .background(Color(AdColorPalette.Background.primary.color))
    }
}

struct ThumbnailOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            //            Color.black.ignoresSafeArea()
            
            ThumbnailOptionView(store: Store(
                initialState: ThumbnailOptionFeature.State(options: ThumbnailDisplayOptions(showOptions: false)),
                reducer: { ThumbnailOptionFeature() }
            ))
        }
    }
}
