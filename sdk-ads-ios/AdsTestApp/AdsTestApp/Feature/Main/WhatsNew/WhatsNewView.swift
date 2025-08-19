//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import MarkdownUI
import AdsCardLibrary

struct WhatsNewView: View {
    let store: StoreOf<WhatsNewFeature>
    var body: some View {
        ScrollView {
            Markdown(store.markdownString)
                .padding()
                .markdownBlockStyle(\.blockquote) { configuration in
                    configuration.label
                        .padding()
                        .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color(AdColorPalette.Primary.supplementary.color).opacity(0.5))
                                .frame(width: 4)
                        }
                        .background(Color(AdColorPalette.Primary.accent.color).opacity(0.5))
                }
                .markdownTextStyle(\.code) {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.85))
                    ForegroundColor(Color(AdColorPalette.Primary.accent.color))
                    BackgroundColor(Color(AdColorPalette.Primary.accent.color).opacity(0.25))
                }
        }
    }
}

#Preview {
    WhatsNewView(store: Store(
        initialState: WhatsNewFeature.State(),
        reducer: {
        WhatsNewFeature()
    }))
}
