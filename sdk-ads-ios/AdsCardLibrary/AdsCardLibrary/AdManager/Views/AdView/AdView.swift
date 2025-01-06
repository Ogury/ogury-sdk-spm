//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct AdView: View {
    let store: StoreOf<AdViewFeature>
    @State private var showErrorAlert = false
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(spacing:2) {
                    HStack(alignment: .center) {
                        if #available(iOS 16.0, *) {
                            TextField("Title", text: viewStore.$baseOptions.adDisplayName)
                                .lineLimit(2, reservesSpace: true)
                                .font(.adsTitle2)
                                .bold()
                                .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_Name")
                        } else {
                            TextField("Title", text: viewStore.$baseOptions.adDisplayName)
                                .font(.adsTitle2)
                                .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_Name")
                        }
                        
                        switch viewStore.adStateEvent {
                            case .adLoading/*, .adDisplaying*/:
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
                                .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_ErrorButton")
                                
                            default: Spacer()
                                
                        }
                        
                        Menu {
                            ControlGroup {
                                Button {
                                    viewStore.send(.showQALabelTapped)
                                } label: {
                                    HStack {
                                        Text("Focus in logs")
                                        Spacer()
                                        Image(systemName:"magnifyingglass")
                                    }
                                }
                                .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_FocusLogsOnCardButton")
                                
                                Button(role: .destructive) {
                                    viewStore.send(.killWebview)
                                } label: {
                                    HStack {
                                        Text("Kill Webview")
                                        Spacer()
                                        Image(systemName: "network.slash")
                                    }
                                }
                                .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_KillWebviewButton")
                            }.safeMenuControlGroupStyle()
                            
                            Button {
                                viewStore.send(.oguryTestModeButtonTapped)
                            } label: {
                                HStack {
                                    Text(viewStore.testModeEnabled
                                         ? "Disable _test mode"
                                         : "Enable _test mode")
                                    Spacer()
                                    Image(systemName: viewStore.testModeEnabled
                                          ? "eraser.line.dashed.fill"
                                          : "wand.and.stars")
                                }
                            }
                            .disabled(!viewStore.showTestModeButton)
                            .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_OguryTestModeButton")
                            
                            Button {
                                viewStore.send(.rtbTestModeButtonTapped)
                            } label: {
                                HStack {
                                    Text(viewStore.rtbTestModeEnabled
                                         ? "Disable RTB test mode"
                                         : "Enable RTB test mode")
                                    Spacer()
                                    Image(systemName: viewStore.rtbTestModeEnabled
                                          ? "eraser.line.dashed.fill"
                                          : "wand.and.stars")
                                }
                            }
                            .disabled(!viewStore.showTestModeButton || !viewStore.isHeaderBidding)
                            .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_RTBTestModeButton")
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .frame(width: 40, height: 40)
                                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        }
                        .padding(.leading, 4)
                        .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_Menu")
                    }
                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 0, trailing: 12))
                    .alert(isPresented: $showErrorAlert) {
                        let alertMessage = (viewStore.error as? OguryErrorConvertible)?.readableError ?? String(describing: viewStore.error)
                        return Alert(title: Text(alertMessage))
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color(AdColorPalette.Background.separator.color))
                        .padding(0)
                        .ignoresSafeArea()
                        .padding(.bottom, 4)
                    
                    Group {
                        VStack(spacing:4) {
                            ZStack(alignment: .topTrailing) {
                                AdsTextField(viewStore.$baseOptions.adUnitId,
                                             placeholder: "Ad Unit Id")
                                .disabled(!viewStore.enableAdUnitEditing)
                                .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_AdUnitField")
                                
                                Spacer()
                                
                                AdTagList(tags: Array(viewStore.tags), size: .small)
                            }
                            
                           HStack(alignment: .bottom, spacing: 8) {
                                if viewStore.baseOptions.showCampaignId {
                                    AdsTextField(viewStore.testModeEnabled
                                                 ? viewStore.$fakeTextState
                                                 : viewStore.$baseOptions.campaignId,
                                                 placeholder: "Campaign Id")
                                    .keyboardType(.numberPad)
                                    .disabled(viewStore.testModeEnabled)
                                    .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_CampaignField")
                                }
                                
                                if viewStore.baseOptions.showCreativeId {
                                    AdsTextField(viewStore.testModeEnabled
                                                 ? viewStore.$fakeTextState
                                                 : viewStore.$baseOptions.creativeId,
                                                 placeholder: "Creative Id")
                                    .keyboardType(.numberPad)
                                    .disabled(viewStore.testModeEnabled)
                                    .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_CreativeField")
                                }
                            }
                            
                            if viewStore.baseOptions.showDspFields {
                                HStack(alignment: .lastTextBaseline) {
                                    AdsTextField(viewStore.testModeEnabled
                                                 ? viewStore.$fakeTextState
                                                 : viewStore.$baseOptions.dspCreativeId,
                                                 placeholder: "DSP Creative Id")
                                    .keyboardType(.numberPad)
                                    .disabled(viewStore.testModeEnabled)
                                    .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_DSPCreativeField")
                                    
                                    Picker("DSP Region", selection: viewStore.$baseOptions.dspRegion) {
                                        ForEach(DspRegion.allCases, id: \.self) { region in
                                            Text(region.displayName)
                                                .font(.adsBody)
                                        }
                                    }
                                    .tint(Color(AdColorPalette.Text.placeholder.color))
                                    .font(.adsBody)
                                    .disabled(viewStore.testModeEnabled)
                                    .fixedSize(horizontal: true, vertical: true)
                                    .pickerStyle(.menu)
                                    .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_DSPRegionField")
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 8, trailing: 12))
                    
                    if viewStore.specificOptions as? BannerAdManagerOptions != nil {
                        BannerPlaceholderView(store:
                                                self.store.scope(state: \.bannerFeature,
                                                                 action: { .bannerAction($0) }
                                                                ))
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Card#\(viewStore.baseOptions.qaLabel)_BannerView")
                    } else if viewStore.rewardedOptions != nil {
                        RewardedView(store: self.store.scope(
                            state: \.rewardedFeature,
                            action: { .rewardedAction($0) }))
                    }
                    
                    if !viewStore.baseOptions.bulkModeEnabled {
                        AdActionBar(store: self.store.scope(state: \.actionBar,
                                                            action: { .adBarAction($0) }))
                        .disabled(viewStore.baseOptions.adUnitId.isEmpty)
                        .padding(EdgeInsets(top: -10, leading: 12, bottom: 0, trailing: 12))
                    }
                }
                .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
                .background(Color(AdColorPalette.Background.primary.color))
                .cornerRadius(8)
                .overlay {
                    if viewStore.baseOptions.isSelected {
                        RoundedRectangle(cornerSize: CGSize(width: 12, height: 12))
                            .stroke(Color(AdColorPalette.Primary.accent.color), lineWidth: 1)
                    }
                }
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
                    case let .showSpecificOptions(value): ViewStore(store, observe: { $0 }).send(.showSpecificOptions(value))
                    case let .enableBulkMode(value): ViewStore(store, observe: { $0 }).send(.enableBulkMode(value))
                    case let .showTestMode(value): ViewStore(store, observe: { $0 }).send(.showTestModeButton(value))
                    case let .forceTestMode(enable): ViewStore(store, observe: { $0 }).send(.forceTestMode(enable))
                    case let .enableFeedbacks(enable): ViewStore(store, observe: { $0 }).send(.enableFeedbacks(enable))
                }
            }
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

//struct InterstitialView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color(AdColorPalette.Background.separator.color).ignoresSafeArea()
//            
//            AdView(store: Store(
//                initialState: AdViewFeature.State(from: 
//                                                   BaseAdManagerOptions(showCampaignId:true, 
//                                                                        showCreativeId:true,
//                                                                        adDisplayName: "Card#1",
//                                                                        adUnitId: "test_test",
//                                                                        campaignId: "campaignId"),
//                                                  adType: AnyAdType(AdType<InterstitialAdManager>.interstitial)),
//                reducer: {
//                    AdViewFeature(adManager: InterstitialAdManager(adType: .interstitial))
//                }))
//            .padding()
//        }
//    }
//}
