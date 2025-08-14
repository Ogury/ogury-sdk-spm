//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary
import SwiftMessages
import AVFoundation

struct AppSettingsView: View {
    let store: StoreOf<AppSettingsFeature>
    let appPermissions: AppPermissions = SettingsController().appPermissions
    var body: some View {
        ZStack {
            AdColorPalette
                .primaryGradient
                .ignoresSafeArea()
            
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                List {
                    
                    //MARK: - SDK start
                    Section {
                        Button {
                            viewStore.send(.startSDKToggleTapped)
                        } label: {
                            HStack {
                                Text("Start SDK with application")
                                    .layoutPriority(1)
                                
                                Toggle("", isOn:
                                        viewStore.binding(
                                            get: \.settings.startSDKWithApplication,
                                            send: .startSDKToggleTapped)
                                )
                            }
                        }
                        .accessibilityLabel("StartSDKWithApplication")
                        
                        HStack {
                            Stepper("Start the SDK \(viewStore.numberOfSDKStart) times",
                                    onIncrement: { viewStore.send(.incrementSDKStart) },
                                    onDecrement: { viewStore.send(.decrementSDKStart) }
                            )
                            .layoutPriority(1)
                            .accessibilityLabel("StartSDKWithApplication_Stepper")
                        }
                        .foregroundStyle(Color(viewStore.startSDKWithApplication ? AdColorPalette.Text.primary(onAccent: false).color : AdColorPalette.Text.placeholder.color))
                        .disabled(viewStore.startSDKWithApplication == false)
                        
                        Button {
                            viewStore.send(.toggleEnableFeedbacks)
                        } label: {
                            HStack {
                                Text("Enable vibration feedbacks")
                                    .layoutPriority(1)
                                
                                Toggle("", isOn:
                                        viewStore.binding(
                                            get: \.settings.enableFeedbacks,
                                            send: .toggleEnableFeedbacks)
                                )
                            }
                        }
                        .accessibilityLabel("EnableFeedbacks")
                        
                        Picker("Import method",
                               selection: viewStore.binding(get: \.importMethod,
                                                            send: { .updateImportMethod($0) })) {
                            ForEach(ImportMethod.allCases, id:\.self) { method in
                                Text(method.shortDisplayText)
                            }
                        }.accessibilityLabel("ImportMethod_Picker")
                    } header: {
                        Text("APPLICATION")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(!appPermissions.settings)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    
                    Section {
                        Button {
                            viewStore.send(.startConsentToggleTapped)
                        } label: {
                            HStack {
                                Text("Start CMP with application")
                                    .layoutPriority(1)
                                
                                Toggle("", isOn:
                                        viewStore.binding(
                                            get: \.settings.startConsentWithApplication,
                                            send: .startConsentToggleTapped)
                                )
                            }
                        }
                        .accessibilityLabel("StartSDKWithApplication")
                        
                        Picker("Choose CMP provider",
                               selection: viewStore.binding(get: \.consentManager,
                                                            send: { .consentManagerSelected($0) })) {
                            ForEach(ConsentManager.allCases, id:\.self) { cmp in
                                Text(cmp.displayName)
                            }
                        }.accessibilityLabel("ImportMethod_Picker")
                    } header: {
                        Text("Consent")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(!appPermissions.settings)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    
                    //MARK: - Hide settings
                    Section {
                        if viewStore.showShowSection {
                            Group {
                                Button {
                                    viewStore.send(.enableFieldsEditingToggleTapped)
                                } label: {
                                    HStack {
                                        Text("Allow fields editing")
                                            .layoutPriority(1)
                                        
                                        Toggle("", isOn:
                                                viewStore.binding(
                                                    get: \.enableFieldsEditing,
                                                    send: .enableFieldsEditingToggleTapped)
                                        )
                                    }
                                }
                                .accessibilityLabel("AllowFieldsEditingToggle")
                                .hidden(!appPermissions.settingPermissions.contains(.showEditFieldsToggle))
                                
                                Button {
                                    viewStore.send(.showCampaignToggleTapped)
                                } label: {
                                    HStack {
                                        Text("Show campaign field")
                                            .layoutPriority(1)
                                        
                                        Toggle("", isOn:
                                                viewStore.binding(
                                                    get: \.showCampaignId,
                                                    send: .showCampaignToggleTapped)
                                        )
                                    }
                                }
                                .accessibilityLabel("ShowCampaignIdToggle")
                                .hidden(!appPermissions.settingPermissions.contains(.showCampaignToggle))
                                
                                Button {
                                    viewStore.send(.showCreativeToggleTapped)
                                } label: {
                                    HStack {
                                        Text("Show creative field")
                                            .layoutPriority(1)
                                        
                                        Toggle("", isOn:
                                                viewStore.binding(
                                                    get: \.showCreativeId,
                                                    send: .showCreativeToggleTapped))
                                    }
                                }
                                .accessibilityLabel("ShowCreativeIdToggle")
                                .hidden(!appPermissions.settingPermissions.contains(.showCreativeToggle))
                                
                                Button {
                                    viewStore.send(.showDspFieldsToggleTapped)
                                } label: {
                                    HStack {
                                        Text("Show dsp creative field")
                                            .layoutPriority(1)
                                        
                                        Toggle("", isOn:
                                                viewStore.binding(
                                                    get: \.showDspFields,
                                                    send: .showDspFieldsToggleTapped))
                                    }
                                }
                                .accessibilityLabel("ShowCreativeFieldsToggle")
                                .hidden(!appPermissions.settingPermissions.contains(.showDspToggle))
                                
                                Button {
                                    viewStore.send(.showTestModeToggleTapped)
                                } label: {
                                    HStack {
                                        Text("Show Test Mode")
                                            .layoutPriority(1)
                                        
                                        Toggle("", isOn:
                                                viewStore.binding(
                                                    get: \.showTestMode,
                                                    send: .showTestModeToggleTapped)
                                        )
                                    }
                                }
                                .accessibilityLabel("ShowTestModeToggle")
                                .hidden(!appPermissions.settingPermissions.contains(.showTestModeToggle))
                                
                                Picker("Kill Webview",
                                       selection: viewStore.binding(get: \.killWebviewMode,
                                                                    send: { .updateKillWebviewMode($0) }))
                                {
                                    ForEach(KillWebviewMode.allCases, id:\.self) { mode in
                                        Text(mode.displayName)
                                            .font(.adsCaption)
                                    }
                                }
                                .accessibilityLabel("ImportMethod_Picker")
                                .hidden(!appPermissions.settingPermissions.contains(.showKillWebviewToggle))
                                
                                if let desc = viewStore.killWebviewMode.description {
                                    HStack {
                                        if let icon = viewStore.killWebviewMode.icon {
                                            icon
                                                .font(.adsTitle)
                                                .foregroundStyle(viewStore.killWebviewMode.displayColor)
                                                .padding(.trailing, 8)
                                                .symbolRenderingMode(.hierarchical)
                                                .safeBreathe()
                                        }
                                        Text(desc)
                                            .font(.adsCaption)
                                            .foregroundStyle(viewStore.killWebviewMode.displayColor)
                                    }
                                    .hidden(!appPermissions.settingPermissions.contains(.showKillWebviewToggle))
                                }
                            }
                        }
                        
                        if !viewStore.showShowSection {
                            Text("Card settings hidden")
                                .font(.adsCaption)
                                .foregroundStyle(Color(AdColorPalette.Text.placeholder.color))
                        }
                        
                    } header: {
                        Button {
                            toggleHideSection(from: viewStore)
                        } label :{
                            HStack {
                                Text("Cards")
                                    .font(.adsBody)
                                    .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    .padding(.horizontal, -16)
                                Spacer()
                                Image(systemName: !viewStore.showShowSection ? "chevron.up" : "chevron.down")
                            }
                        }
                    }
                    .disabled(!appPermissions.settings)
                    .listRowSeparator(.hidden)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    .hidden(appPermissions.settingPermissions.contains(.noCards))
                    
                    //MARK: - Profig settings
                    Section {
                        Button {
                            viewStore.send(.bulkModeToggleTapped)
                        } label: {
                            HStack {
                                Text("Enable bulk mode")
                                Toggle("", isOn:
                                        viewStore.binding(
                                            get: \.settings.bulkModeEnabled,
                                            send: .bulkModeToggleTapped)
                                )
                            }
                        }
                        .accessibilityLabel("EnableBulkModeToggle")
                    } header: {
                        Text("Bulk mode")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(true)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    .hidden(!appPermissions.settingPermissions.contains(.showResetProfigToggle))
                    
                    //MARK: - Test Mode
                    Section {
                        HStack {
                            Button{
                                viewStore.send(.enabledTestModeButtonTapped)
                            } label : {
                                Text("Enable for all cards")
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AdsSecondaryButton())
                            .accessibilityLabel("EnableTestModeForAllCardsButton")
                            
                            Button{
                                viewStore.send(.disabledTestModeButtonTapped)
                            } label : {
                                Text("Disable for all cards")
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AdsSecondaryButton())
                            .accessibilityLabel("DisableTestModeForAllCardsButton")
                        }
                        .padding(.horizontal, -20)
                    } header: {
                        Text("Test Mode")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(!appPermissions.settings)
                    .listRowBackground(Color.clear)
                    .hidden(!appPermissions.settingPermissions.contains(.showTestModeToggle))
                    
                    //MARK: - Profig settings
                    Section {
                        Button("Reset Ads config file (profig)") {
                            viewStore.send(.resetAdConfigButtonTapped)
                        }
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: true).color))
                        .accessibilityLabel("ResetProfigButton")
                    } header: {
                        Text("Ads config")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(!appPermissions.settings)
                    .listRowBackground(Color(AdColorPalette.State.failure.color))
                    .hidden(!appPermissions.settingPermissions.contains(.showResetProfigToggle))
                    
                    //MARK: - Profig settings
                    Section {
                        Button {
                            viewStore.send(.usOptoutTapped)
                        } label: {
                            HStack {
                                Text("US Opt-out")
                                Toggle("", isOn:
                                        viewStore.binding(
                                            get: \.usOptout,
                                            send: .usOptoutTapped)
                                )
                            }
                        }
                        .accessibilityLabel("USOptOutButton")
                        
                        Button {
                            viewStore.send(.usOptoutPartnerTapped)
                        } label: {
                            HStack {
                                Text("US Opt-out Partner")
                                Toggle("", isOn:
                                        viewStore.binding(
                                            get: \.usOptoutPartner,
                                            send: .usOptoutPartnerTapped)
                                )
                            }
                        }
                        .accessibilityLabel("USOptOuPartnertButton")
                        
                        NavigationLink(
                            destination: PrivacyDataView().navigationTitle("Privacy Data")
                        ) {
                            Text("Retrieve Privacy data")
                        }
                        .accessibilityLabel("RetrievePrivacyDataButton")
                        .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                        
                        Button {
                            viewStore.send(.copyIdfaButtonTapped)
                        } label: {
                            HStack {
                                Text("Copy IDFA to clipboard")
                            }
                        }
                        .accessibilityLabel("CopyIdfaButton")
                        
                    } header: {
                        Text("Privacy")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(!appPermissions.settings)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    
                    //MARK: - Audio
                    Section {
                        Picker("Audio mode",
                               selection: viewStore.binding(get: \.audioMode,
                                                            send: { .audioModeSelected($0) })) {
                            ForEach(AVAudioSession.Mode.allCases, id:\.self) { mode in
                                if let name = mode.displayName {
                                    Text(name)
                                } else {
                                    EmptyView()
                                }
                            }
                        }.accessibilityLabel("AudioMode_Picker")
                        
                        Picker("Audio category",
                               selection: viewStore.binding(get: \.audioCategory,
                                                            send: { .audioCategorySelected($0) })) {
                            ForEach(AVAudioSession.Category.allCases, id:\.self) { cat in
                                if let name = cat.displayName {
                                    Text(name)
                                } else {
                                    EmptyView()
                                }
                            }
                        }.accessibilityLabel("AudioCategory_Picker")
                        
                    } header: {
                        Text("Audio Session")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    .hidden(!appPermissions.settingPermissions.contains(.showAudioToggle))
                    
                    //MARK: - Logs settings
#if canImport(OguryAds)
                    Section {
                        NavigationLink(
                            destination: LogOptionView().navigationTitle("Log options")
                        ) {
                            Text("Show options")
                        }
                        .accessibilityLabel("ShowLogOptionsNavigationLink")
                    } header: {
                        Text("Logs")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(!appPermissions.settings)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    .hidden(!appPermissions.logs)
#endif
                    
                    Spacer()
                        .listRowBackground(Color.clear)
                }
                .safeScrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .tint(Color(AdColorPalette.Text.primary(onAccent: false).color))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func toggleHideSection(from viewStore: ViewStoreOf<AppSettingsFeature>) {
        let _ = withAnimation {
            viewStore.send(.toggleShowShowSection)
        }
    }
}

public extension Text {
    func safeItalic(_ isActive: Bool) -> Text {
        if #available(iOS 16.0, *) {
            return self.italic(isActive)
        } else {
            return self
        }
    }
}

extension View {
    func safeBreathe() -> some View {
        if #available(iOS 18.0, *) {
            return self.symbolEffect(.breathe, isActive: true)
        } else {
            return self
        }
    }
}

//#Preview {
//    NavigationView(content: {
//        AppSettingsView( store: Store(
//            initialState: AppSettingsFeature.State(settings: SettingsContainer(), adDelegate: nil),
//            reducer: { AppSettingsFeature() }
//        ))
//    })
//}
