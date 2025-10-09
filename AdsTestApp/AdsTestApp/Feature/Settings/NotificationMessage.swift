//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

import SwiftUI
import SwiftMessages
import AdsCardLibrary

struct NotificationMessage: Identifiable {
    let title: String
    let body: String
    let style: NotificationMessageView.Style
    
    var id: String { title + body }
}

extension NotificationMessage: MessageViewConvertible {
    func asMessageView() -> NotificationMessageView {
        NotificationMessageView(message: self, style: style)
    }
}

#Preview {
    NotificationMessageView(message: NotificationMessage(title: "Title",
                                                         body: "This is the message",
                                                         style: .card),
                            style: .card)
}

// A message view with a title and message.
struct NotificationMessageView: View {
    
    // MARK: - API
    
    enum Style {
        case standard
        case card
        case tab
    }
    
    let message: NotificationMessage
    let style: Style
    
    
    // MARK: - Variables
    
    // MARK: - Constants
    
    // MARK: - Body
    
    var body: some View {
        switch style {
            case .standard:
                content()
                // Mask the content and extend background into the safe area.
                    .mask {
                        Rectangle()
                            .edgesIgnoringSafeArea(.top)
                    }
                
            case .card:
                content()
                // Mask the content with a rounded rectangle
                    .mask {
                        RoundedRectangle(cornerRadius: 15)
                    }
                // External padding around the card
                    .padding(10)
                
            case .tab:
                content()
                // Mask the content with rounded bottom edge and extend background into the safe area.
                    .mask {
                        if #available(iOS 16.0, *) {
                            UnevenRoundedRectangle(bottomLeadingRadius: 15, bottomTrailingRadius: 15)
                                .edgesIgnoringSafeArea(.top)
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .edgesIgnoringSafeArea(.top)
                        }
                    }
        }
    }
    
    @ViewBuilder private func content() -> some View {
        HStack(spacing:0) {
            Spacer()
            
            Image(systemName: "i.circle")
                .foregroundStyle(Color(AdColorPalette.Primary.accent.color))
            
            VStack(alignment: .leading) {
                Text(message.title)
                    .font(.adsTitle)
                
                Text(message.body)
                    .font(.adsBody)
            }
            .multilineTextAlignment(.leading)
            // Internal padding of the card
            .padding(30)
            // Greedy width
            
            Spacer()
        .background(Color(AdColorPalette.Background.primary.color))
        }
    }
}
