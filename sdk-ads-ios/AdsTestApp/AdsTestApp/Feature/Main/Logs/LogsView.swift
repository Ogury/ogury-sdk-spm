//
//  LogsView.swift
//  AdsTestApp
//
//  Created by nicolas perret on 25/10/2024.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct LogsView: View {
    let store: StoreOf<LogsFeature>
    @State private var logsSubscription: AnyCancellable?
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
           ScrollView {
              VStack(alignment: .leading, spacing: 0) {
                 HStack {
                    Text("Logs")
                       .font(.title2)
                    Spacer()
                    Button {
                       viewStore.send(.clearLogs)
                    } label: {
                       Image(systemName: "trash")
                    }
                 }
                 ForEach(viewStore.logMessages.indices, id: \.self) { index in
                    Text(AttributedString(viewStore.logMessages[index]))
                       .padding(.horizontal)
                       .padding(.vertical, 8)
                       .cornerRadius(8)
                       .overlay (
                          Divider()
                             .padding(.leading),
                          alignment : .bottom
                       )
                 }
              }
           }
           .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
               logsSubscription = TestAppLogController.shared.logger.logs
                  .receive(on: DispatchQueue.main)
                  .sink { logMessages in
                     viewStore.send(.receiveLog(logMessages))
                  }
            }
            .onDisappear {
                logsSubscription?.cancel()
                logsSubscription = nil
            }
        }
    }
}
