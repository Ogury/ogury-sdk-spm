//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary
import AdsCardAdapter

struct MainView: View {
    let store: StoreOf<MainFeature>
    let logsStore: StoreOf<LogsFeature>
    let appPermissions: AppPermissions = SettingsController().appPermissions
    @State private var logsHeight: CGFloat = 150
    @State private var keyboardShown: Bool = false
    @State private var logViewSearching: Bool = false
    @Environment(\.cardPermissions) var cardPermissions
    
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
                
                if viewStore.showLogs, !keyboardShown, !viewStore.adFormats.isEmpty {
                    VStack {
                        VStack {
                            LogsView(
                                store: logsStore,
                                logsHeight: $logsHeight,
                                isSearching:$logViewSearching
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
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if !logViewSearching {
                    keyboardShown = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                keyboardShown = false
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolBarContent(viewStore: viewStore)
            }
            .toolbarBackground(Color(AdColorPalette.Background.primary.color), for: .navigationBar)
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
        if appPermissions.bulkMode {
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
        }
        
        if appPermissions.logs,
            !viewStore.adFormats.isEmpty {
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
        }
        
        if appPermissions.add {
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
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                if appPermissions.export {
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
                }
                
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
                
                Section {
                    ForEach(SdkLauncher.shared.adapter.actions, id: \.name) { action in
                        Button{
                            action.perform()
                        } label: {
                            HStack {
                                Text(action.name).font(.adsBody)
                                if let icon = action.icon {
                                    icon
                                }
                            }
                        }
                    }
                    Button{
                        viewStore.send(.aboutButtonTapped)
                    } label: {
                        HStack {
                            Text("About").font(.adsBody)
                            Image(systemName: "info.circle")
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
                                    .accessibilityLabel("ImportSheetCancelButton")
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
                        NavigationView {
                            AppSettingsView(store: store)
                                .toolbar {
                                    ToolbarItem(placement: .topBarLeading) {
                                        Button {
                                            viewStore.send(.destination(.dismiss))
                                        } label: {
                                            Text("Dismiss")
                                        }
                                        .accessibilityLabel("SettingsSheetCancelButton")
                                    }
                                }
                        }
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
    let adFormat: any AdAdapterFormat
    let managers: [any AdManager]
    let geometry: GeometryProxy
    @State private var contentSize: CGSize = .zero
    @Environment(\.cardPermissions) var cardPermissions
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            adFormat.displayIcon
                .resizable()
                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio
                .frame(width: 50, height: 50) // Sets the frame size
                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(adFormat.adFormat.name.capitalized) (\(managers.count))")
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
    let adFormat: any AdAdapterFormat
    let managers: [any AdManager]
    let geometry: GeometryProxy
    // we block the navigation for all banner managers since we have issues with adViews and superviews
    var disabled: Bool { managers.first?.adFormat == .standardBanner }
    @State private var contentSize: CGSize = .zero
    @Environment(\.cardPermissions) var cardPermissions
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 4) {
                    adFormat.displayIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit) // Maintains the aspect ratio
                        .frame(width: 50, height: 50) // Sets the frame size
                        .offset(y: 3)
                        .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(adFormat.adFormat.name) (\(managers.count))")
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
    @Environment(\.cardPermissions) var cardPermissions
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                List {
                    VStack(alignment: .center) {
                        TextField("Set name",
                                  text: viewStore.$setName,
                                  prompt: Text("Name your ads set"))
                        .font(.adsLargeTitle)
                        .foregroundStyle(
                            Color(viewStore.setName != SettingsContainer.untitledAdSet
                                  ? AdColorPalette.Text.primary(onAccent: false).color
                                  : AdColorPalette.Text.placeholder.color)
                        )
                    }
                    .padding(8)
                    .padding(.horizontal, -10)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        ForEach(viewStore.adFormats.sorted(by: { $0 < $1 })) { adCardList in
                            if #available(iOS 16.0, *) {
                                HorizontalCardsView(adFormat: adCardList.adAdapterFormat,
                                                    managers: adCardList.adManagers,
                                                    geometry: geometry)
                                .frame(width: geometry.size.width)
                            } else {
                                LegacyHorizontalCardsView(adFormat: adCardList.adAdapterFormat,
                                                          managers: adCardList.adManagers,
                                                          geometry: geometry)
                                .background(Color.clear)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
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
    let appPermissions: AppPermissions = SettingsController().appPermissions
    
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
                if appPermissions.add {
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
                }
                
                if appPermissions.export {
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
