import SwiftUI
import ComposableArchitecture

struct LogsFeature: Reducer {
    struct State: Equatable {
        var logMessages: [NSAttributedString] = []
    }
    
    enum Action: Equatable {
       case receiveLog(NSAttributedString)
       case clearLogs
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
       switch action {
       case .receiveLog(let log):
          state.logMessages.append(log)
          return .none
       case .clearLogs:
          state.logMessages.removeAll()
          return .none
       }
    }
}
