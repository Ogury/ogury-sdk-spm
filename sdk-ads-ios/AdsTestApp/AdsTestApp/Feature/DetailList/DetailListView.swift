//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import AdsCardLibrary

struct DetailListView: View {
    let store: StoreOf<DetailListFeature>
//    @State var toolbarVisible: Bool = false
    
    var body: some View {
        
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color(AdColorPalette.Background.secondary.color).ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        AdTagList(tags: viewStore.adFormat.tags)
                        Spacer()
                    }
                    
                    List {
                        ForEach(0..<viewStore.state.adManagers.count, id: \.self) { index in
                            viewStore.state.adManagers[index].adView
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical)
                                .padding(.horizontal, 5)
                        }
                    }
                    .safeScrollDismissesKeyboard()
                    .safeScrollContentBackground(.hidden)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if viewStore.toolbarVisible {
                            HStack {
                                Spacer()
                                
                                Button("Close") {
                                    store.send(.endEditing)
                                }
                                .font(.adsBody)
                                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let _ = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        viewStore.send(.showToolbar)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    viewStore.send(.hideToolbar)
                }
            }
            .navigationTitle(Text("\(viewStore.state.adFormat.title.capitalized) (\(viewStore.state.adManagers.count))"))
            .accentColor(Color(AdColorPalette.Primary.accent.color))
        }
        
    }
}

public extension View {
    func safeScrollContentBackground(_ visibility: Visibility) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(visibility)
        } else {
            return self.background(Color.clear)
        }
    }
    func safeScrollDismissesKeyboard() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollDismissesKeyboard(.interactively)
        } else {
            return self.background(Color.clear)
        }
    }
    
}

#Preview {
    DetailListView( store: Store(initialState: DetailListFeature.State(adManagers: [], adFormat: AdFormat(id: 0, adType: AnyAdType(AdType<InterstitialAdManager>.interstitial))), reducer: {
        DetailListFeature()
    }))
}
