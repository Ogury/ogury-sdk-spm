//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import AdsCardLibrary

struct PrivacyDataView: View {
    let store: StoreOf<PrivacyDataFeature> = .init(initialState: .init(), reducer: { PrivacyDataFeature() })
    var body: some View {
        List {
            ForEach(store.data, id: \.self) { data in
                Section {
                    if let value = data.value {
                        VStack {
                            Text(value)
                                .font(.adsCaption)
                            
                            if data.canCopy {
                                LabeledContent("") {
                                    Button("Copy") {
                                        store.send(.saveToClipboard(value))
                                    }
                                    .buttonStyle(AdsPrimaryButton())
                                }
                            }
                        }
                    } else {
                        Text("No data found")
                            .font(.adsBody)
                    }
                } header: {
                    Text(data.title)
                }
            }
        }
    }
}

#Preview {
    PrivacyDataView()
}
