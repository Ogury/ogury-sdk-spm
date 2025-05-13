//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture

public struct AdView: View {
    @Perception.Bindable var store: StoreOf<AdViewFeature>
    @State private var showErrorAlert = false
    @Environment(\.cardPermissions) var cardPermissions
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing:2) {
                //MARK: Title HStack
                HStack(alignment: .center) {
                    TextField("Title", text: $store.cardName)
                        .lineLimit(2, reservesSpace: true)
                        .font(.adsTitle2)
                        .bold()
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .accessibilityLabel("Card#\(store.qaLabel)_Name")
                    
                    switch store.adStateEvent {
                        case .adLoading:
                            ProgressView()
                                .tint(Color(AdColorPalette.Primary.supplementary.color))
                                .padding(.trailing, 3)
                            
                        case .adLoaded:
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color(AdColorPalette.State.success.color))
                            
                        case .adDidFail, .adDidFailToLoad, .adDidFailToDisplay:
                            Button {
                                showErrorAlert = true
                            } label: {
                                if #available(iOS 16, *) {
                                    Image(systemName: "checkmark.circle.badge.xmark.fill")
                                        .font(.title3)
                                        .tint(Color(AdColorPalette.State.failure.color))
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .tint(Color(AdColorPalette.State.failure.color))
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .accessibilityLabel("Card#\(store.qaLabel)_ErrorButton")
                            
                        default: Spacer()
                    }
                    
                    //MARK: Cell menu
                    WithPerceptionTracking {
                        Menu {
                            if store.adManager.cardConfiguration.killWebviewMode == .none {
                                Button {
                                    store.send(.showQALabelTapped)
                                } label: {
                                    HStack {
                                        Text("Focus in logs")
                                        Spacer()
                                        Image(systemName:"magnifyingglass")
                                    }
                                }
                                .accessibilityLabel("Card#\(store.qaLabel)_FocusLogsOnCardButton")
                                .hidden(!cardPermissions.logs)
                            } else {
                                ControlGroup {
                                    Button {
                                        store.send(.showQALabelTapped)
                                    } label: {
                                        HStack {
                                            Text("Focus in logs")
                                            Spacer()
                                            Image(systemName:"magnifyingglass")
                                        }
                                    }
                                    .accessibilityLabel("Card#\(store.qaLabel)_FocusLogsOnCardButton")
                                    .hidden(!cardPermissions.logs)
                                    
                                    Button(role: store.adManager.cardConfiguration.killWebviewMode == .simulate ? .cancel : .destructive) {
                                        store.send(.killWebview)
                                    } label: {
                                        HStack {
                                            Text("Kill Webview\n(\(store.adManager.cardConfiguration.killWebviewMode.displayName))")
                                            Spacer()
                                            Image(systemName: "network.slash")
                                        }
                                    }
                                    .accessibilityLabel("Card#\(store.qaLabel)_KillWebviewButton")
                                    .hidden(!cardPermissions.devFeatures)
                                }.safeMenuControlGroupStyle()
                            }
                            
                            Button {
                                store.send(.oguryTestModeButtonTapped)
                            } label: {
                                HStack {
                                    Text(store.testModeEnabled
                                         ? "Disable _test mode"
                                         : "Enable _test mode")
                                    Spacer()
                                    Image(systemName: store.testModeEnabled
                                          ? "eraser.line.dashed.fill"
                                          : "wand.and.stars")
                                }
                            }
                            .disabled(!store.showTestModeButton)
                            .accessibilityLabel("Card#\(store.qaLabel)_OguryTestModeButton")
                            .hidden(!cardPermissions.devFeatures)
                            
                            Button {
                                store.send(.rtbTestModeButtonTapped)
                            } label: {
                                HStack {
                                    Text(store.rtbTestModeEnabled
                                         ? "Disable RTB test mode"
                                         : "Enable RTB test mode")
                                    Spacer()
                                    Image(systemName: store.rtbTestModeEnabled
                                          ? "eraser.line.dashed.fill"
                                          : "wand.and.stars")
                                }
                            }
                            .disabled(!store.showTestModeButton || !store.showRtbTestMode)
                            .accessibilityLabel("Card#\(store.qaLabel)_RTBTestModeButton")
                            .hidden(!cardPermissions.devFeatures)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .frame(width: 40, height: 40)
                                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        }
                        .padding(.leading, 4)
                        .accessibilityLabel("Card#\(store.qaLabel)_Menu")
                        // play with `opacity` instead of `hidden` to keep the 40:40 frame
                        .opacity(cardPermissions.showCardMenu ? 1 : 0)
                    }
                }
                .padding(EdgeInsets(top: 6, leading: 12, bottom: 0, trailing: 12))
                .alert(isPresented: $showErrorAlert) {
                    let alertMessage = (store.error as? ErrorConvertible)?.readableError ?? String(describing: store.error)
                    return Alert(title: Text(alertMessage))
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color(AdColorPalette.Background.separator.color))
                    .padding(0)
                    .ignoresSafeArea()
                    .padding(.bottom, 4)
                
                //MARK: Textfields
                Group {
                    VStack(spacing:4) {
                        ZStack(alignment: .topTrailing) {
                            AdsTextField($store.adUnitId,
                                         placeholder: "Ad Unit Id")
                            .disabled(!store.enableAdUnitEditing)
                            .accessibilityLabel("Card#\(store.qaLabel)_AdUnitField")
                            
                            Spacer()
                            
                            AdTagList(tags: Array(store.tags), size: .small)
                        }
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            if store.showCampaignId {
                                AdsTextField(store.testModeEnabled
                                             ? $store.fakeTextState
                                             : $store.campaignId,
                                             placeholder: "Campaign Id")
                                .keyboardType(.numberPad)
                                .disabled(store.testModeEnabled)
                                .accessibilityLabel("Card#\(store.qaLabel)_CampaignField")
                            }
                            
                            if store.showCreativeId {
                                AdsTextField(store.testModeEnabled
                                             ? $store.fakeTextState
                                             : $store.creativeId,
                                             placeholder: "Creative Id")
                                .keyboardType(.numberPad)
                                .disabled(store.testModeEnabled)
                                .accessibilityLabel("Card#\(store.qaLabel)_CreativeField")
                            }
                        }
                        
                        if store.showDspFields {
                            HStack(alignment: .lastTextBaseline) {
                                AdsTextField(store.testModeEnabled
                                             ? $store.fakeTextState
                                             : $store.dspCreativeId,
                                             placeholder: "DSP Creative Id")
                                .keyboardType(.numberPad)
                                .disabled(store.testModeEnabled)
                                .accessibilityLabel("Card#\(store.qaLabel)_DSPCreativeField")
                                
                                Picker("DSP Region", selection: $store.dspRegion) {
                                    ForEach(DspRegion.allCases, id: \.self) { region in
                                        Text(region.displayName)
                                            .font(.adsBody)
                                    }
                                }
                                .tint(Color(AdColorPalette.Text.placeholder.color))
                                .font(.adsBody)
                                .disabled(store.testModeEnabled)
                                .fixedSize(horizontal: true, vertical: true)
                                .pickerStyle(.menu)
                                .accessibilityLabel("Card#\(store.qaLabel)_DSPRegionField")
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 8, trailing: 12))
                
                //MARK: Specific views for banner and rewardedVideos
                WithPerceptionTracking {
                    if store.isBanner {
                        BannerPlaceholderView(store:store.scope(state: \.bannerFeature, action: \.bannerAction))
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Card#\(store.qaLabel)_BannerView")
                    } else if store.isRewardedVideo {
                        RewardedView(store: store.scope(state: \.rewardedFeature, action: \.rewardedAction))
                    }
                }
                
                //MARK: ActionBar for load actions
                if !store.adManager.cardConfiguration.bulkModeEnabled {
                    AdActionBar(store: store.scope(state: \.actionBar, action: \.adBarAction))
                    .disabled(store.adUnitId.isEmpty)
                    .padding(EdgeInsets(top: -10, leading: 12, bottom: 0, trailing: 12))
                }
            }
            .alert(store: self.store.scope(state: \.$alert, action:\.alert))
            .background(Color(AdColorPalette.Background.primary.color))
            .cornerRadius(8)
            .frame(minWidth: 280)
            .shadow(color: Color(AdColorPalette.Background.shadow.color), radius: 5, x: 0, y: 8)
        }
    }
    
    public func updateCard(events: [AdOptionsEvent]) {
        withAnimation {
            events.forEach { event in
                switch event {
                    case let .enableAdUnitEditing(value): ViewStore(store, observe: { $0 }).send(.enableAdUnitEditing(value))
                    case let .showCampaignId(value): ViewStore(store, observe: { $0 }).send(.showCampaignId(value))
                    case let .showCreativeId(value): ViewStore(store, observe: { $0 }).send(.showCreativeId(value))
                    case let .showDspFields(value): ViewStore(store, observe: { $0 }).send(.showDspFields(value))
                    case let .enableBulkMode(value): ViewStore(store, observe: { $0 }).send(.enableBulkMode(value))
                    case let .showTestMode(value): ViewStore(store, observe: { $0 }).send(.showTestModeButton(value))
                    case let .forceTestMode(enable): ViewStore(store, observe: { $0 }).send(.forceTestMode(enable))
                    case let .enableFeedbacks(enable): ViewStore(store, observe: { $0 }).send(.enableFeedbacks(enable))
                    case let .updateKillMode(mode): ViewStore(store, observe: { $0 }).send(.updateKillMode(mode))
                }
            }
        }
    }
}

public extension View {
    public func safeMenuControlGroupStyle() -> some View {
        if #available(iOS 16.4, *) {
            return self.controlGroupStyle(.menu)
        } else {
            return self.controlGroupStyle(.automatic)
        }
    }
    
    func hidden(_ condition: Bool) -> some View {
        Group {
            if condition {
                EmptyView()
            } else {
                self
            }
        }
    }
}

//#Preview {
//    NewAdViewView(store: Store(
//        initialState: NewAdViewFeature.State(),
//        reducer: {
//        NewAdViewFeature()
//    }))
//}
