import SwiftUI
import ComposableArchitecture
import AdsCardLibrary

struct DetailListView: View {
    let store: StoreOf<DetailListFeature>
    let logsStore: StoreOf<LogsFeature>
    @State private var logsHeight: CGFloat = 100

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

               LogsView(
                   store: logsStore,
                   logsHeight: $logsHeight
               )
                .background(Color(AdColorPalette.Background.primary.color))
                .shadow(radius: 3)
                .frame(height: logsHeight)
                .padding(.top, 8)
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .navigationTitle(Text("\(viewStore.adFormat.title.capitalized) (\(viewStore.adManagers.count))"))
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

// Preview Setup
#Preview {
    DetailListView( store: Store(initialState: DetailListFeature.State(adManagers: [], adFormat: AdFormat(id: 0, adType: AnyAdType(AdType<InterstitialAdManager>.interstitial))), reducer: {
        DetailListFeature()
    }), logsStore: Store(initialState: LogsFeature.State() ,reducer: {LogsFeature()}))
}
