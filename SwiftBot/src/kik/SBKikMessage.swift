public enum KikMessageType {
    case Text
    case Picture
    case Video
    case Link
    case StartChatting
    case ScanData
    case Sticker

    func toString() -> String {
        switch self {
        case .Text:
            return "text"
        case .Picture:
            return "picture"
        case .Video:
            return "video"
        case .Link:
            return "link"
        case .StartChatting:
            return "start-chatting"
        case .ScanData:
            return "scan-data"
        case .Sticker:
            return "sticker"
        }
    }
}

public enum KikKeyboardType {
    case Suggested
}

internal struct KikKeyboard {
    let keyboardType: KikKeyboardType = .Suggested
    let responses: [KikSuggestedResponse]

    init(suggestedResponses: [String]) {
        self.responses = suggestedResponses.map {
            KikSuggestedResponse(type: .Text, body: $0)
        }
    }
}

internal struct KikSuggestedResponse {
    let type: KikMessageType
    let body: String
}

public typealias KikUser = String
public protocol KikMessage: SBMessage {
    var type: KikMessageType { get }
    var chatId: String { get }
    var id: String { get }
    var from: KikUser { get }
    var participants: [KikUser]? { get }
    var timestamp: Int64 { get }
    var mention: String? { get }
    var to: KikUser? { get }
}

public protocol KikAttribution {
    var name: String { get }
    var iconURL: NSURL { get }
}

public protocol KikVideoMessage: KikMessage {
    var videoURL: NSURL { get }
    var loop: Bool { get }
    var muted: Bool { get }
    var autoPlay: Bool { get }
    var noSave: Bool { get }
    var attribution: KikAttribution { get }
}

public protocol KikTextMessage: KikMessage {
    var body: String { get }
}

public protocol KikPictureMessage: KikMessage {
    var pictureURL: NSURL { get }
    var attribution: KikAttribution { get }
}

public protocol KikMessageSend: SBMessage {
    var type: KikMessageType { get }
    var chatId: String { get }
    var to: KikUser { get }
    var suggestedResponses: [String]? { get }
}

extension KikMessageSend {
    internal func toJSON() -> JSON {
        return [String: AnyObject]()
    }
}

extension KikTextMessageSend {
    internal func toJSON() -> JSON {
        return [
//            "chatId": self.chatId,
            "to": self.to,
            "type": self.type.toString(),
            "body": self.body,
        ]
    }
}

public protocol KikTextMessageSend: KikMessageSend {
    var body: String { get }
}
