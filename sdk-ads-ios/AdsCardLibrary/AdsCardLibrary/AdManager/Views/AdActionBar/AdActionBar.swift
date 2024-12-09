//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct AdActionBar: View {
    @Environment(\.isEnabled) private var isEnabled
    let store: StoreOf<AdActionBarFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack(spacing: 8) {
                Group {
                    Button("Load") {
                        viewStore.send(.loadButtonTapped)
                    }
                    .accessibilityLabel("Card#\(viewStore.qaLabel)_LoadButton")
                    
                    Button("Show") {
                        viewStore.send(.showButtonTapped)
                    }
                    .accessibilityLabel("Card#\(viewStore.qaLabel)_ShowButton")
                    
                    Button("Load & Show") {
                        viewStore.send(.loadAndShowButtonTapped)
                    }
                    .accessibilityLabel("Card#\(viewStore.qaLabel)_LoadAndShowButton")
                }
                .buttonStyle(AdsPrimaryButton(isEnabled: isEnabled))
                
                Spacer()
                
                Divider()
                    .frame(width: 0.35, height: 35)
                    .overlay(Color(AdColorPalette.Background.separator.color))
                    .padding(.vertical)
                
                Spacer()
                
                Button {
                    viewStore.send(.deleteButtonTapped)
                } label: {
                    Image(systemName: "trash")
                        .tint(Color(AdColorPalette.State.failure.color))
                }
                .accessibilityLabel("Card#\(viewStore.qaLabel)_DeleteButton")
                .padding(4)
                .buttonStyle(AdsDefaultButton(color: AdColorPalette.State.failure.color))
                .foregroundStyle(Color(AdColorPalette.Text.primary(onAccent: true).color))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .buttonStyle(BorderlessButtonStyle())
            }
            .background(Color(AdColorPalette.Background.primary.color))
        }
    }
}

struct AdActionBar_Previews: PreviewProvider {
    static var previews: some View {
        AdActionBar(store: Store(initialState: AdActionBarFeature.State(qaLabel: "QALabel"), reducer: {
            AdActionBarFeature()
        }))
        //        .disabled(true)
    }
}

public struct AdsPrimaryButton: ButtonStyle {
    private var isEnabled: Bool
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.adsTitle3)
            .padding(8)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color(AdColorPalette.Background.shadow.color), radius: 3.5, x: 0, y: 5)
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        switch (isEnabled, isPressed) {
            case (false, _): return Color(AdColorPalette.Background.disabled.color)
            case (_, true): return Color(AdColorPalette.Primary.accentLight.color)
            case (_, false): return Color(AdColorPalette.Primary.accent.color)
        }
    }
    private func foregroundColor(isPressed: Bool) -> Color {
        switch (isEnabled, isPressed) {
            case (false, _): return Color(AdColorPalette.Text.supplementary(onAccent: false).color)
            case (_, false): return Color(AdColorPalette.Text.primary(onAccent: true).color)
            case (_, true): return Color(AdColorPalette.Text.supplementary(onAccent: false).color)
        }
    }
}

public struct AdsExpandablePrimaryButton: ButtonStyle {
    private var isEnabled: Bool
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.adsTitle3)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color(AdColorPalette.Background.shadow.color), radius: 3.5, x: 0, y: 5)
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        switch (isEnabled, isPressed) {
            case (false, _): return Color(AdColorPalette.Background.disabled.color)
            case (_, true): return Color(AdColorPalette.Primary.accentLight.color)
            case (_, false): return Color(AdColorPalette.Primary.accent.color)
        }
    }
    private func foregroundColor(isPressed: Bool) -> Color {
        switch (isEnabled, isPressed) {
            case (false, _): return Color(AdColorPalette.Text.supplementary(onAccent: false).color)
            case (_, false): return Color(AdColorPalette.Text.primary(onAccent: true).color)
            case (_, true): return Color(AdColorPalette.Text.supplementary(onAccent: false).color)
        }
    }
}

public struct AdsSecondaryButton: ButtonStyle {
    private var isEnabled: Bool
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.adsTitle3)
            .padding(8)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        switch (isEnabled, isPressed) {
            case (false, _): return Color(AdColorPalette.Background.disabled.color)
            case (_, true): return Color(AdColorPalette.Primary.accent.color)
            case (_, false): return Color(AdColorPalette.Primary.accentLight.color)
        }
    }
    private func foregroundColor(isPressed: Bool) -> Color {
        switch (isEnabled, isPressed) {
            case (false, _): return Color(AdColorPalette.Text.supplementary(onAccent: false).color)
            case (_, true): return Color(AdColorPalette.Text.primary(onAccent: true).color)
            case (_, false): return Color(AdColorPalette.Text.supplementary(onAccent: false).color)
        }
    }
}

public struct AdsDefaultButton: ButtonStyle {
    let color: UIColor
    init(color: UIColor) {
        self.color = color
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.adsTitle3)
            .padding(8)
            .background(Color(configuration .isPressed ? (color.darker() ?? color) : color))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

public extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    fileprivate func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
