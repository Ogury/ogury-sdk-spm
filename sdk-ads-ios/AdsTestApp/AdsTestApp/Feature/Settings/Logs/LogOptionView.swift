//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary

#if canImport(OguryAds)
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
                                
                                WithPerceptionTracking {
                                    Toggle("", isOn: Binding<Bool> {
                                        viewStore.state.state(for: logDisplay)
                                    } set: { activated in
                                        viewStore.send(.logDisplayButtonTapped(logDisplay))
                                    })
                                }
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
                    ForEach(OguryLogType.allCases, id: \.rawValue) { logType in
                        VStack {
                            HStack {
                                Button {} label: {
                                    Circle()
                                        .fill(
                                            viewStore.state.color(for: logType)
                                        )
                                        .onTapGesture {
                                            viewStore.send(.selectPickerForLogType(logType))
                                        }
                                        .frame(width: 30, height: 30)
                                        .padding(.trailing, 8)
                                }
                                
                                Button {
                                    viewStore.send(.logTypeButtonTapped(logType))
                                } label: {
                                    HStack {
                                        Text(logType.displayName)
                                            .font(.adsBody)
                                            .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                                        
                                        WithPerceptionTracking {
                                            Toggle("", isOn: Binding<Bool>{
                                                viewStore.state.state(for: logType)
                                            } set: { newValue in
                                                viewStore.send(.logTypeButtonTapped(logType))
                                            })
                                        }
                                    }
                                }
                                .accessibilityLabel("LogSettingsAllowInternalLogsToggle")
                            }
                            
                            WithPerceptionTracking {
                                if viewStore.showColorPicker, viewStore.selectedType == logType {
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
#endif

//#Preview {
//    NavigationView {
//        LogOptionView()
//    }
//}
