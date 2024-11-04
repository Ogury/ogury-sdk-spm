import SwiftUI
import ComposableArchitecture

struct LogsFeature: Reducer {
    struct State: Equatable {
        var logMessages: [NSAttributedString] = []
        fileprivate var unfilteredMessages: [NSAttributedString] = []  {
            didSet {
                updateFilteredMessages()
            }
        }
        
        var filter: String = "" {
            didSet {
                updateFilteredMessages()
            }
        }
        
        mutating func updateFilteredMessages() {
            guard !filter.isEmpty else {
                logMessages = unfilteredMessages
                return
            }
            logMessages = unfilteredMessages.filter({ $0.string.lowercased().contains(filter.lowercased()) })
        }
    }
    
    enum Action: Equatable {
        case receiveLog(NSAttributedString)
        case clearLogs
        case filter(String)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            case .receiveLog(let log):
                state.unfilteredMessages.append(log)
                return .none
                
            case .clearLogs:
                state.unfilteredMessages.removeAll()
                return .none
                
            case let .filter(filter):
                state.filter = filter
                return .none
        }
    }
}
