//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
import ComposableArchitecture
import AdsCardLibrary

struct ImportView: View {
    let store: StoreOf<ImportFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("Paste the content of your JSON raw file")
                    .font(.adsBody)
                    .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: false).color))
                
                TextEditor(text: viewStore.$jsonText)
                    .font(.custom("FiraCode-Regular", fixedSize: 12))
                    .cornerRadius(12)
                    .clipped()
                    .frame(maxHeight: .infinity)
                    .padding()
                
                HStack {
                    Button("Paste clipboard") {
                        viewStore.send(.pasteFromClipboard)
                    }
                    .buttonStyle(AdsExpandablePrimaryButton())
                    
                    Button("Import json") {
                        viewStore.send(.importButtonTapped(viewStore.jsonText))
                    }
                    .buttonStyle(AdsExpandablePrimaryButton(isEnabled: viewStore.validJson))
                    .disabled(!viewStore.validJson)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(AdColorPalette.Background.secondary.color))
        }
    }
}

#Preview {
    ImportView(store: Store(
        initialState: ImportFeature.State(), 
        reducer: {
        ImportFeature()
    }))
}
