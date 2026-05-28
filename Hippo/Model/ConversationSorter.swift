// MARK: - Mode

public enum SmartChatOrderMode {
    case defaultChannelsFirst
    case activeChatsFirst
    case timeBased(minutes: Int)
}

// MARK: - Config

public struct SmartChatOrderConfig {
    public let mode: SmartChatOrderMode

    public init(mode: SmartChatOrderMode) {
        self.mode = mode
    }

    public static func parse(from dict: [String: Any]) -> SmartChatOrderConfig? {
        if (dict["show_default_channels"] as? String) == "1" {
            return SmartChatOrderConfig(mode: .defaultChannelsFirst)
        }
        if (dict["show_active_chats"] as? String) == "1" {
            return SmartChatOrderConfig(mode: .activeChatsFirst)
        }
        if let timeStr = dict["show_time_based_chats"] as? String,
           let minutes = Int(timeStr.components(separatedBy: " ").first ?? ""),
           minutes > 0 {
            return SmartChatOrderConfig(mode: .timeBased(minutes: minutes))
        }
        return nil
    }
}

// MARK: - Sorter

struct ConversationSorter {
    static func sort(_ conversations: [FuguConversation], config: SmartChatOrderConfig) -> [FuguConversation] {
        switch config.mode {
        case .defaultChannelsFirst:
            return conversations.filter { isDefault($0) }.sortedByDate()
                 + conversations.filter { !isDefault($0) }.sortedByDate()

        case .activeChatsFirst:
            return conversations.filter { !isDefault($0) }.sortedByDate()
                 + conversations.filter { isDefault($0) }.sortedByDate()

        case .timeBased(let minutes):
            let cutoff = Date().addingTimeInterval(-Double(minutes) * 60)
            let defaults = conversations.filter { isDefault($0) }.sortedByDate()
            let regular  = conversations.filter { !isDefault($0) }
            let recent   = regular.filter { ($0.lastMessage?.creationDateTime ?? .distantPast) >= cutoff }.sortedByDate()
            let older    = regular.filter { ($0.lastMessage?.creationDateTime ?? .distantPast) < cutoff }.sortedByDate()
            return defaults + recent + older
        }
    }

    private static func isDefault(_ conv: FuguConversation) -> Bool {
        return (conv.channelId ?? 0) <= 0
    }
}

private extension Array where Element == FuguConversation {
    func sortedByDate() -> [FuguConversation] {
        sorted {
            ($0.lastMessage?.creationDateTime ?? .distantPast) >
            ($1.lastMessage?.creationDateTime ?? .distantPast)
        }
    }
}
