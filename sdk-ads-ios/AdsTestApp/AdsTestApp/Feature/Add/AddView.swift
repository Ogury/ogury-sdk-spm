//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import AdsCardLibrary

struct AddView: View {
    let store: StoreOf<AddFeature>
    @State var value = 0
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                AdColorPalette
                    .primaryGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    ForEach(viewStore.binding(
                        get: \.sections,
                        send: AddFeature.Action.setSections), id:\.id) { $section in
                            VStack(alignment: .leading) {
                                Text(section.title)
                                    .font(.adsTitle2)
                                    .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach($section.adFormats, id:\.id) { $adFormat in
                                            AddFormatView(value: $adFormat.nbOfFormatToLoad,
                                                          title: adFormat.addCardTitle)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                }
                .padding()
            }
            .shadow(color: Color(AdColorPalette.Background.shadow.color), radius: 5, x: 0, y: 8)
        }
    }
}

#Preview {
    AddView(
      store: Store(initialState: AddFeature.State(maxHeaderBidable: MaxBidder(), dtFairBidHeaderBidable: DTFairBidBidder()),
                     reducer: {
                         AddFeature()
                     }))
}
