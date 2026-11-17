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
            // Default channels follow the business's channel_priority (0, 1, 2...), not
            // recency; the regular chats after them stay newest first.
            return conversations.filter { isDefault($0) }.sortedByPriority()
                 + conversations.filter { !isDefault($0) }.sortedByDate()

        case .activeChatsFirst:
            // Regular chats newest first, then the default channels by channel_priority.
            return conversations.filter { !isDefault($0) }.sortedByDate()
                 + conversations.filter { isDefault($0) }.sortedByPriority()

        case .timeBased(let minutes):
            // One window for both kinds, then four groups:
            //   recent channels (by priority) -> recent chats (newest first)
            //   -> older channels (by priority) -> older chats (newest first).
            // A channel's activity is its last message time, same as a chat's.
            let cutoff = Date().addingTimeInterval(-Double(minutes) * 60)
            func isRecent(_ conv: FuguConversation) -> Bool {
                (conv.lastMessage?.creationDateTime ?? .distantPast) >= cutoff
            }
            let channels = conversations.filter { isDefault($0) }
            let chats    = conversations.filter { !isDefault($0) }
            return channels.filter(isRecent).sortedByPriority()
                 + chats.filter(isRecent).sortedByDate()
                 + channels.filter { !isRecent($0) }.sortedByPriority()
                 + chats.filter { !isRecent($0) }.sortedByDate()
        }
    }

    /// A default channel is either still unstarted (no real channel id yet) or a chat
    /// that was started from one - the backend keeps its label_id (> 0) and real
    /// channel_priority then, while ordinary chats carry label_id -1.
    private static func isDefault(_ conv: FuguConversation) -> Bool {
        return (conv.channelId ?? 0) <= 0 || (conv.labelId ?? 0) > 0
    }
}

private extension Array where Element == FuguConversation {
    /// Lowest channel_priority first; a missing priority goes last. Equal priorities fall
    /// back to newest first, so the order is stable and predictable.
    func sortedByPriority() -> [FuguConversation] {
        sorted {
            let lhs = $0.channelPriority ?? Int.max
            let rhs = $1.channelPriority ?? Int.max
            if lhs != rhs { return lhs < rhs }
            return ($0.lastMessage?.creationDateTime ?? .distantPast) >
                   ($1.lastMessage?.creationDateTime ?? .distantPast)
        }
    }

    func sortedByDate() -> [FuguConversation] {
        sorted {
            ($0.lastMessage?.creationDateTime ?? .distantPast) >
            ($1.lastMessage?.creationDateTime ?? .distantPast)
        }
    }
}
