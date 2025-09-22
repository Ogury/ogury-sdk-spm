//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//


import SwiftUI
internal import ComposableArchitecture
import MarkdownUI
import AdsCardLibrary
import ConfettiSwiftUI

struct WhatsNewView: View {
    let store: StoreOf<WhatsNewFeature>
    @State var triggerConfetti = false
    var body: some View {
        ScrollView {
            // just for the confetti to be on top
            Circle()
                .opacity(0)
                .frame(width: 1, height: 1)
                .confettiCannon(trigger: $triggerConfetti,
                                num: 100,
                                openingAngle: Angle(degrees: 0),
                                closingAngle: Angle(degrees: 360),
                                radius: 200,
                                repetitions: 2,
                                repetitionInterval: 0.5,
                                hapticFeedback: true)
            
            WithPerceptionTracking {
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
        .onAppear {
            if store.showConfetti {
                triggerConfetti.toggle()
            }
        }
        .navigationTitle("What's new in \(About().appName) ?")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    WhatsNewView(store: Store(
        initialState: WhatsNewFeature.State(markdownString: "## title", showConfetti: true),
        reducer: {
        WhatsNewFeature()
    }))
}
