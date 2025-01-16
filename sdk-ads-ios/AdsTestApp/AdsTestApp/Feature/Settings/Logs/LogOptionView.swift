//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import AdsCardLibrary
import OguryAds

struct LogOptionView: View {
    @BindingState var store: StoreOf<LogOptionFeature> = .init(
        initialState: LogOptionFeature.State(),
        reducer: { LogOptionFeature() }
    )
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                Section {
                    ForEach(OguryLogDisplay.allCases, id:\.rawValue) { logDisplay in
                        Button {
                            viewStore.send(.logDisplayButtonTapped(logDisplay))
                        } label: {
                            HStack {
                                Text(logDisplay.displayName)
                                    .layoutPriority(1)
                                
                                Toggle("", isOn: Binding<Bool> {
                                    viewStore.state.state(for: logDisplay)
                                } set: { activated in
                                    viewStore.send(.logDisplayButtonTapped(logDisplay))
                                })
                            }
                        }
                        .accessibilityLabel("LogSettingsDisplaySDKToggle")
                    }
                    
                } header: {
                    Text("Display")
                        .font(.adsBody)
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .padding(.horizontal, -16)
                }
                .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                .listRowBackground(Color(AdColorPalette.Background.secondary.color))
                
                //MARK: - LOG TYPES
                Section {
                    VStack {
                        HStack {
                            Button {} label: {
                                Circle()
                                    .fill(
                                        viewStore.logTypeInternalColor
                                    )
                                    .onTapGesture {
//                                        withAnimation {
                                            viewStore.send(.selectPickerForLogType(.internal))
//                                        }
                                    }
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                            }
                            
                            Button {
                                viewStore.send(.logTypeInternalButtonTapped)
                            } label: {
                                HStack {
                                    Text("Internal")
                                        .font(.adsBody)
                                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.logTypeInternalEnabled,
                                                send: .logTypeInternalButtonTapped)
                                    )
                                }
                            }
                            .accessibilityLabel("LogSettingsAllowInternalLogsToggle")
                        }
                        
                        if viewStore.showColorPicker, viewStore.selectedType == .internal {
                            ColorPicker("Pick your color",
                                        selection: viewStore.binding(get: \.color,
                                                                     send: { .selectColor($0) }),
                                        supportsOpacity: false)
                                .onChange(of: store.color) { newColor in
                                    viewStore.send(.selectColor(newColor))
                                }
                                .transition(.slide)
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button {} label: {
                                Circle()
                                    .fill(
                                        viewStore.logTypePublisherColor
                                    )
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                                    .onTapGesture {
                                        viewStore.send(.selectPickerForLogType(.publisher))
                                    }
                            }
                            
                            Button {
                                viewStore.send(.logTypePublisherButtonTapped)
                            } label: {
                                HStack {
                                    Text("Publisher")
                                        .font(.adsBody)
                                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.logTypePublisherEnabled,
                                                send: .logTypePublisherButtonTapped)
                                    )
                                }
                            }
                            .accessibilityLabel("LogSettingsAllowPublisherLogsToggle")
                        }
                        
                        if viewStore.showColorPicker, viewStore.selectedType == .publisher {
                            ColorPicker("Pick your color",
                                        selection: viewStore.binding(get: \.color,
                                                                     send: { .selectColor($0) }),
                                        supportsOpacity: false)
                            .onChange(of: store.color) { newColor in
                                viewStore.send(.selectColor(newColor))
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button {} label: {
                                Circle()
                                    .fill(
                                        viewStore.logTypeDelegateColor
                                    )
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                                    .onTapGesture {
                                        viewStore.send(.selectPickerForLogType(.delegate))
                                    }
                            }
                            
                            Button {
                                viewStore.send(.logTypeDelegateButtonTapped)
                            } label: {
                                HStack {
                                    Text("Triggered callbacks")
                                        .font(.adsBody)
                                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.logTypeDelegateEnabled,
                                                send: .logTypeDelegateButtonTapped)
                                    )
                                }
                            }
                            .accessibilityLabel("LogSettingsAllowDelegateLogsToggle")
                        }
                        
                        if viewStore.showColorPicker, viewStore.selectedType == .delegate {
                            ColorPicker("Pick your color",
                                        selection: viewStore.binding(get: \.color,
                                                                     send: { .selectColor($0) }),
                                        supportsOpacity: false)
                            .onChange(of: store.color) { newColor in
                                viewStore.send(.selectColor(newColor))
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button {} label: {
                                Circle()
                                    .fill(
                                        viewStore.logTypeMonitoringColor
                                    )
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                                    .onTapGesture {
                                        viewStore.send(.selectPickerForLogType(.monitoring))
                                    }
                            }
                            
                            Button {
                                viewStore.send(.logTypeMonitoringButtonTapped)
                            } label: {
                                HStack {
                                    Text("Monitoring")
                                        .font(.adsBody)
                                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.logTypeMonitoringEnabled,
                                                send: .logTypeMonitoringButtonTapped)
                                    )
                                }
                            }
                            .accessibilityLabel("LogSettingsAllowMonitoringLogsToggle")
                        }
                        
                        if viewStore.showColorPicker, viewStore.selectedType == .monitoring {
                            ColorPicker("Pick your color",
                                        selection: viewStore.binding(get: \.color,
                                                                     send: { .selectColor($0) }),
                                        supportsOpacity: false)
                            .onChange(of: store.color) { newColor in
                                viewStore.send(.selectColor(newColor))
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button {} label: {
                                Circle()
                                    .fill(
                                        viewStore.logTypeMraidColor
                                    )
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                                    .onTapGesture {
                                        viewStore.send(.selectPickerForLogType(.mraid))
                                    }
                            }
                            
                            Button {
                                viewStore.send(.logTypeMraidButtonTapped)
                            } label: {
                                HStack {
                                    Text("Mraid")
                                        .font(.adsBody)
                                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.logTypeMraidEnabled,
                                                send: .logTypeMraidButtonTapped)
                                    )
                                }
                            }
                            .accessibilityLabel("LogSettingsAllowMraidLogsToggle")
                        }
                        
                        if viewStore.showColorPicker, viewStore.selectedType == .mraid {
                            ColorPicker("Pick your color",
                                        selection: viewStore.binding(get: \.color,
                                                                     send: { .selectColor($0) }),
                                        supportsOpacity: false)
                            .onChange(of: store.color) { newColor in
                                viewStore.send(.selectColor(newColor))
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            Button {} label: {
                                Circle()
                                    .fill(
                                        viewStore.logTypeRequestColor
                                    )
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                                    .onTapGesture {
                                        viewStore.send(.selectPickerForLogType(.requests))
                                    }
                            }
                            
                            Button {
                                viewStore.send(.logTypeRequestButtonTapped)
                            } label: {
                                HStack {
                                    Text("Requests")
                                        .font(.adsBody)
                                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                    Toggle("", isOn:
                                            viewStore.binding(
                                                get: \.logTypeRequestEnabled,
                                                send: .logTypeRequestButtonTapped)
                                    )
                                }
                            }
                            .accessibilityLabel("LogSettingsAllowRequestsLogsToggle")
                        }
                        
                        if viewStore.showColorPicker, viewStore.selectedType == .requests {
                            ColorPicker("Pick your color",
                                        selection: viewStore.binding(get: \.color,
                                                                     send: { .selectColor($0) }),
                                        supportsOpacity: false)
                            .onChange(of: store.color) { newColor in
                                viewStore.send(.selectColor(newColor))
                            }
                        }
                    }
                } header: {
                    Text("Log Types")
                        .font(.adsCaption)
                        .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                        .padding(.horizontal, -16)
                }
                .foregroundColor(Color(AdColorPalette.Text.primary(onAccent: false).color))
                .listRowBackground(Color(AdColorPalette.Background.secondary.color))
            }
            .safeScrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tint(Color(AdColorPalette.Text.primary(onAccent: false).color))
        }
    }
}

//#Preview {
//    NavigationView {
//        LogOptionView()
//    }
//}
