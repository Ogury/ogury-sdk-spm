//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import AdsCardLibrary

struct MainView: View {
    let store: StoreOf<MainFeature>
    let logsStore: StoreOf<LogsFeature>
    @State private var logsHeight: CGFloat = 150
   
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
           VStack(spacing:0) {
              ZStack {
                   Color(AdColorPalette.Background.secondary.color).ignoresSafeArea()
                   
                   if viewStore.adFormats.isEmpty {
                       EmptyManagersView(viewStore: viewStore)
                   } else {
                       ListManagersView(store: store)
                           .listStyle(InsetListStyle())
                           .frame(width: UIScreen.main.bounds.size.width, alignment: .center)
                           .accessibilityLabel("CardList")
                   }
               }
               
               if viewStore.showLogs {
                   VStack {
                       VStack {
                           LogsView(
                            store: logsStore,
                            logsHeight: $logsHeight
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
           }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolBarContent(viewStore: viewStore)
            }
            .tint(Color(AdColorPalette.Primary.accent.color))
            .addViewModifiers(store: store, viewStore: viewStore)
        }
    }
   
    private func showAddView(from viewStore: ViewStoreOf<MainFeature>) {
        let _ = withAnimation {
            viewStore.send(.addButtonTapped)
        }
    }
    
    @ToolbarContentBuilder
    func toolBarContent(viewStore: ViewStore<MainFeature.State, MainFeature.Action>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewStore.send(.bulkModeButtonTapped)
            } label: {
                Image(systemName: "list.bullet")
                    // just to increase a little bit the touching area
                    .frame(height: 40)
            }
            .foregroundStyle(Color(AdColorPalette.Background.placeholder.color))
            .accessibilityLabel("NavBarBulkModeButton")
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewStore.send(.showLogs(!viewStore.showLogs))
            } label: {
                Image("console")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(
                        Color(viewStore.showLogs
                              ? AdColorPalette.Primary.accent.color
                              : UIColor.gray)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    // just to increase a little bit the touching area
                    .frame(height: 40)
            }
            .accessibilityLabel("NavBarLogButton")
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddView(from: viewStore)
            } label: {
                Image(systemName: "plus")
                    // just to increase a little bit the touching area
                    .frame(height: 40)
            }
            .accessibilityLabel("NavBarAddButton")
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                    ControlGroup {
                        Button{
                            viewStore.send(.exportButtonTapped)
                        } label: {
                            HStack {
                                Text("Export").font(.adsBody)
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        .disabled(viewStore.adFormats.isEmpty)
                        
                        Button {
                            viewStore.send(.importButtonTapped)
                        } label: {
                            HStack {
                                Text("Import").font(.adsBody)
                                Image(systemName: "square.and.arrow.down")
                            }
                        }
                        
                        Button(role: .destructive) {
                            viewStore.send(.removeSetButtonTapped)
                        } label: {
                            HStack {
                                Text("Clear").font(.adsBody)
                                Image(systemName: "clear")
                            }
                        }
                        .disabled(viewStore.adFormats.isEmpty)
                    }
                    .safeMenuControlGroupStyle()
                
                Section {
                    Button{
                        viewStore.send(.startSDKButtonTapped)
                    } label: {
                        HStack {
                            Text("Start Ads SDK").font(.adsBody)
                            Image(systemName: "power.circle")
                        }
                    }
                    Button{
                        viewStore.send(.showConsentButtonTapped)
                    } label: {
                        HStack {
                            Text("Show consent notice").font(.adsBody)
                            Image(systemName: "doc.text.magnifyingglass")
                        }
                    }
                    Button{
                        viewStore.send(.settingsButtonTapped)
                    } label: {
                        HStack {
                            Text("Settings").font(.adsBody)
                            Image(systemName: "gear")
                        }
                    }
                }
                
            } label: {
                Image(systemName: "ellipsis")
                    // just to increase a little bit the touching area
                    .frame(height: 40)
            }
            .accessibilityLabel("NavBarSettingsButton")
        }
    }
}

extension View {
    fileprivate func addViewModifiers(store: StoreOf<MainFeature>,
                                      viewStore: ViewStore<MainFeature.State, MainFeature.Action>) -> some View {
        self
            .alert(
                store: store.scope(
                    state: \.$destination,
                    action: MainFeature.Action.destination
                ),
                state: /MainFeature.Destination.State.alert,
                action: MainFeature.Destination.Action.alert
            )
            .sheet(
                store: store.scope(
                    state: \.$destination,
                    action: MainFeature.Action.destination
                ),
                state: /MainFeature.Destination.State.import,
                action: MainFeature.Destination.Action.import) { store in
                    NavigationStack {
                        ImportView(store: store)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button {
                                        viewStore.send(.destination(.dismiss))
                                    } label: {
                                        Text("Cancel")
                                    }
                                }
                            }
                    }
                    .background(.gray)
                }
            .sheet(
                store: store.scope(
                    state: \.$destination,
                    action: MainFeature.Action.destination
                ),
                state: /MainFeature.Destination.State.settings,
                action: MainFeature.Destination.Action.settings) { store in
                    AppSettingsView(store: store)
                }
                .sheet(
                  store: store.scope(
                     state: \.$destination,
                     action: MainFeature.Action.destination
                  ),
                  state: /MainFeature.Destination.State.add,
                  action: MainFeature.Destination.Action.add,
                  content: { store in
                    if #available(iOS 16.0, *) {
                        AddSheetView(store: store, viewStore: viewStore)
                            .presentationDetents([.fraction(0.7)])
                            .presentationBackgroundInteraction(.disabled)
                    } else {
                        AddSheetView(store: store, viewStore: viewStore)
                    }
                 })
                    
    }
}

//#Preview {
//    NavigationView {
//        MainView(store: Store(initialState: MainFeature.State(), reducer: {
//            MainFeature(adHostingViewController: UIViewController(), adDelegate: nil)
//        }), logsStore: Store(initialState: LogsFeature.State() ,reducer: {LogsFeature()}))
//    }
//}

@available(iOS, introduced: 15, deprecated: 16, message: "use ListManagersView for iOS 16+")
struct LegacyHorizontalCardsView: View {
    let adFormat: AdFormat
    let managers: [any AdManager]
    let geometry: GeometryProxy
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let image = adFormat.displayIcon {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit) // Maintains the aspect ratio
                    .frame(width: 50, height: 50) // Sets the frame size
                    .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(adFormat.title.capitalized) (\(managers.count))")
                    .font(.adsTitle)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        Color(AdColorPalette.Text.placeholder.color)
                    )
                
                AdTagList(tags: adFormat.tags)
            }
        }
//        .frame(width: UIScreen.main.bounds.size.width - 30,
//               alignment: .leading)
        
        TabView {
            ForEach(0..<managers.count, id: \.self) { index in
                managers[index]
                    .adView
                    .padding(.horizontal, 20)
                    .frame(width: geometry.size.width)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                contentSize = geo.size
                            }
                        }
                    )
            }
        }
        .zIndex(0)
        .frame(width: geometry.size.width,
               height: contentSize.height + (managers.isEmpty ? 0 : 70))
        .tabViewStyle(.page)
    }
}

@available(iOS 16, *)
struct HorizontalCardsView: View {
    let adFormat: AdFormat
    let managers: [any AdManager]
    let geometry: GeometryProxy
    // we block the navigation for all banner managers since we have issues with adViews and superviews
    var disabled: Bool { managers.first as? BannerAdManager != nil }
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 4) {
                    if let image = adFormat.displayIcon {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Maintains the aspect ratio
                            .frame(width: 50, height: 50) // Sets the frame size
                            .offset(y: 3)
                            .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(adFormat.title.capitalized) (\(managers.count))")
                            .font(.adsTitle)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                disabled
                                ? Color(AdColorPalette.Text.placeholder.color)
                                : Color(AdColorPalette.Text.primary(onAccent: false).color)
                        )
                        
                        AdTagList(tags: adFormat.tags)
                            .zIndex(2)
                    }
                }
                .zIndex(1)
                
                NavigationLink(
                    state: AppFeature.Path.State.detail(
                        DetailListFeature.State(adManagers: managers, adFormat: adFormat)
                    )
                ) {
                    EmptyView()
                }
                .disabled(disabled)
                .frame(width: geometry.size.width - 30,
                   alignment: .leading)
            }
            
            TabView {
                ForEach(0..<managers.count, id: \.self) { index in
                    managers[index]
                        .adView
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .frame(width: geometry.size.width)
                        .overlay(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    contentSize = geo.size
                                }
                            }
                        )
                }
            }
            .zIndex(0)
            .frame(width: geometry.size.width,
                   height: contentSize.height + (managers.isEmpty ? 0 : 30))
            .tabViewStyle(.page)
        }
    }
}

struct ListManagersView: View {
    let store: StoreOf<MainFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                List {
                    Section {
                        ForEach(viewStore.adFormats.sorted(by: { lhs, rhs in
                            lhs.key.sortPosition < rhs.key.sortPosition
                        }).map({ $0.key })) { adFormat in
                            let managers = viewStore.adFormats[adFormat] ?? []
                            if #available(iOS 16.0, *) {
                                HorizontalCardsView(adFormat: adFormat,
                                                    managers: managers,
                                                    geometry: geometry)
                                .frame(width: geometry.size.width)
                            } else {
                                LegacyHorizontalCardsView(adFormat: adFormat,
                                                          managers: managers,
                                                          geometry: geometry)
                                .background(Color.clear)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } header: {
                        VStack(alignment: .center) {
                            Text("Beta version - for tests only")
                                .padding(.vertical, 3)
                                .padding(.horizontal, 12)
                                .background(Color(AdColorPalette.State.failure.color.lighter(by: 75) ?? AdColorPalette.State.failure.color))
                                .foregroundStyle(Color(AdColorPalette.State.failure.color))
                                .clipShape(Capsule())
                            
                            TextField("Set name",
                                      text: viewStore.$setName,
                                      prompt: Text("Name your ads set"))
                            .font(.adsLargeTitle)
                        }
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .padding(8)
                        .padding(.horizontal, -10)
                    }
                }
                .safeScrollDismissesKeyboard()
                .safeScrollContentBackground(.hidden)
            }
        }
    }
}

struct EmptyManagersView: View {
    var viewStore: ViewStore<MainFeature.State, MainFeature.Action>
    
    var body: some View {
        VStack {
            Image("folder")
                .resizable()
                .frame(width: 150, height: 150)
            
            Text("There is nothing to display")
                .font(.adsHheadline)
                .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                .padding()
            
            VStack(spacing: 16) {
                Button {
                    showAddView(from: viewStore)
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add ad units")
                            .font(.adsTitle2)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(AdsPrimaryButton())
                
                Button {
                    viewStore.send(.importButtonTapped)
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import saved")
                            .font(.adsTitle2)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(AdsSecondaryButton())
            }
        }
    }
    
    private func showAddView(from viewStore: ViewStoreOf<MainFeature>) {
        let _ = withAnimation {
            viewStore.send(.addButtonTapped)
        }
    }
}

struct AddSheetView: View {
    var store: Store<AddFeature.State, AddFeature.Action>
    var viewStore: ViewStore<MainFeature.State, MainFeature.Action>
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                AddView(store: store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                viewStore.send(.cancelAddButtonTapped)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                viewStore.send(.addFormatButtonTapped)
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Select ad units")
                    .accentColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .font(.adsTitle2)
            }
        } else {
            NavigationView(content: {
                AddView(store: store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                viewStore.send(.cancelAddButtonTapped)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                viewStore.send(.addFormatButtonTapped)
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Select ad units")
                    .accentColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .font(.adsTitle2)
            })
        }
    }
}

extension View {
    public func safeMenuControlGroupStyle() -> some View {
        if #available(iOS 16.4, *) {
            return self.controlGroupStyle(.menu)
        } else {
            return self.controlGroupStyle(.automatic)
        }
    }
}
