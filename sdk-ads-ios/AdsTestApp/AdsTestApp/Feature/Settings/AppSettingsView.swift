//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import AdsCardLibrary
import SwiftMessages

struct AppSettingsView: View {
    let store: StoreOf<AppSettingsFeature>
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
                    } header: {
                        Text("APPLICATION")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    
                    //MARK: - Hide settings
                    Section {
                        if viewStore.showShowSection {
                            Group {
                                Button {
                                    viewStore.send(.enableAdUnitEditingToggleTapped)
                                } label: {
                                    HStack {
                                        Text("Allow AdUnit editing")
                                            .layoutPriority(1)
                                      
                                        Toggle("", isOn:
                                                viewStore.binding(
                                                    get: \.enableAdUnitEditing,
                                                    send: .enableAdUnitEditingToggleTapped)
                                        )
                                    }
                                }
                                
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
                            }
                            
                            Button {
                                viewStore.send(.showSpecificOptionsToggleTapped)
                            } label: {
                                HStack {
                                    Text("Show specific options")
                                        .layoutPriority(1)

                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.showSpecificOptions,
                                                send: .showSpecificOptionsToggleTapped)
                                    )
                                }
                            }
                            
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
                        }
                        
                        if !viewStore.showShowSection {
                            Divider()
                                .listRowBackground(Color.clear)
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
                    .listRowSeparator(.hidden)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    
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
                    } header: {
                        Text("Bulk mode")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .disabled(true)
                    .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                    .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                    
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
                            
                            Button{
                                viewStore.send(.disabledTestModeButtonTapped)
                            } label : {
                                Text("Disable for all cards")
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AdsSecondaryButton())
                        }
                        .padding(.horizontal, -20)
                    } header: {
                        Text("Test Mode")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .listRowBackground(Color.clear)
                    
                    //MARK: - Profig settings
                    Section {
                        Button("Reset Ads config file (profig)") {
                            viewStore.send(.resetAdConfigButtonTapped)
                        }
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: true).color))
                    } header: {
                        Text("Ads config")
                            .font(.adsBody)
                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                            .padding(.horizontal, -16)
                    }
                    .listRowBackground(Color(AdColorPalette.State.failure.color))
                    .disabled(true)
                    
                    Spacer()
                        .listRowBackground(Color.clear)
                    
                    //MARK: - settings
                    VStack(alignment: .center) {
                        Text("App Version : \(viewStore.appVersion)")
                        Text("Ads SDK Version : \(viewStore.sdkVersion)")
                        Text("Environment : \(viewStore.environment)")
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .foregroundStyle(Color(AdColorPalette.Text.placeholder.color))
                    .font(.caption)
                }
                .safeScrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .tint(Color(AdColorPalette.Text.primary(onAccent: false).color))
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

#Preview {
    NavigationView(content: {
        AppSettingsView( store: Store(
            initialState: AppSettingsFeature.State(settings: SettingsContainer(), adDelegate: nil),
            reducer: { AppSettingsFeature() }
        ))
    })
}
