import SwiftUI
internal import ComposableArchitecture

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
        var logsAsString: String {
            unfilteredMessages
                .map{ $0.string }
                .joined(separator: "\n\n")
        }
    }
    
    enum Action: Equatable {
        case receiveLog(NSAttributedString)
        case clearLogs
        case filter(String)
        case logViewDidAppear
        case logViewDidDisappear
    }
    
    enum LogCancel: Hashable {
        case disppear
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
                
            case .logViewDidAppear:
                return .publisher {
                    TestAppLogController.shared.logger.logs
                        .receive(on: DispatchQueue.main)
                        .map{ .receiveLog($0) }
                }
                .cancellable(id: LogCancel.disppear)
                
            case .logViewDidDisappear:
                return .cancel(id: LogCancel.disppear)
        }
    }
}
