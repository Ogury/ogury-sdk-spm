import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary

struct DetailListView: View {
    let store: StoreOf<DetailListFeature>
    let logsStore: StoreOf<LogsFeature>
    @State private var logsHeight: CGFloat = 150
    @State private var logViewSearching: Bool = false

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                ZStack {
                    Color(AdColorPalette.Background.secondary.color).ignoresSafeArea()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            AdTagList(tags: viewStore.adFormat.tags)
                            Spacer()
                        }
                        
                        List {
                            ForEach(0..<viewStore.adManagers.count, id: \.self) { index in
                                viewStore.adManagers[index].adView
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
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if viewStore.toolbarVisible {
                            HStack {
                                Spacer()
                                Button("Close") {
                                    viewStore.send(.endEditing)
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

               VStack {
                  VStack {
                     LogsView(
                         store: logsStore,
                         logsHeight: $logsHeight,
                         isSearching: $logViewSearching
                     )
                       .padding()
                       .frame(maxWidth: .infinity, maxHeight: .infinity)
                  }
                  .background(Color(AdColorPalette.Background.primary.color))
                  .ignoresSafeArea()
                  .cornerRadius(15)
                  .shadow(radius: 3)
               }
               .background(Color(AdColorPalette.Background.secondary.color))
               .ignoresSafeArea()
               .frame(height: logsHeight)
            }
            .navigationTitle(Text("\(viewStore.adFormat.displayName.capitalized) (\(viewStore.adManagers.count))"))
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

//// Preview Setup
//#Preview {
//    DetailListView( store: Store(initialState: DetailListFeature.State(adManagers: [], adFormat: AdFormat(id: 0, adType: AnyAdType(AdType<InterstitialAdManager>.interstitial))), reducer: {
//        DetailListFeature()
//    }), logsStore: Store(initialState: LogsFeature.State() ,reducer: {LogsFeature()}))
//}
