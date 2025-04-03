//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary

struct AppView: View {
    let store: StoreOf<AppFeature>
    @State private var toolbarVisible = false
    private var cardPermissions: CardPermissions {
        CardPermissions(logs: SettingsController().appPermissions.logs,
                        add: SettingsController().appPermissions.add,
                        devFeatures: SettingsController().appPermissions.devFeatures)
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStackStore(
                store.scope(state: \.path, action: { .path($0) })
            ) {
                MainView(
                    store: store.scope(
                        state: \.main,
                        action: { .main($0) }
                    ), logsStore:  self.store.scope(state: \.logs, action: AppFeature.Action.logs)
                )
                .environment(\.cardPermissions, cardPermissions)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if toolbarVisible {
                            HStack {
                                if #available(iOS 17.0, *) {
                                    Spacer()
                                }
                                
                                Button("Close") {
                                    store.send(.endEditing)
                                }
                                .font(.adsBody)
                                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                            }
                            .padding()
                            .id("toolbarVisible")  // Force a view update by adding an ID
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let _ = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        toolbarVisible = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    toolbarVisible = false
                }
            } destination: { state in
                switch state {
                    case .main:
                        CaseLet(
                            /AppFeature.Path.State.main,
                             action: AppFeature.Path.Action.main,
                             then: { store in
                                MainView(store: store, logsStore: self.store.scope(state: \.logs, action: AppFeature.Action.logs))
                            }
                        )
                    case .detail:
                        CaseLet(
                            /AppFeature.Path.State.detail,
                             action: AppFeature.Path.Action.detail,
                             then: { store in
                                DetailListView(store: store, logsStore: self.store.scope(state: \.logs, action: AppFeature.Action.logs))
                            }
                        )
                }
            }
        } else {
            NavigationView(content: {
                MainView(
                    store: self.store.scope(
                        state: \.main,
                        action: { .main($0) }
                    ), logsStore:  self.store.scope(state: \.logs, action: AppFeature.Action.logs)
                )
            })
        }
    }
}

//#Preview {
//    AppView(store: Store(initialState: AppFeature.State(), reducer: {
//        AppFeature(adHostingViewController: nil, adDelegate: nil)
//    }))
//}
