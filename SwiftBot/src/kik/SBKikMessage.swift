public enum SBKikMessageType {
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

public enum SBKikKeyboardType {
    case Suggested
}

internal struct KikKeyboard {
    let keyboardType: SBKikKeyboardType = .Suggested
    let responses: [SBKikSuggestedResponse]

    init(suggestedResponses: [String]) {
        self.responses = suggestedResponses.map {
            SBKikSuggestedResponse(type: .Text, body: $0)
        }
    }
}

internal struct SBKikSuggestedResponse {
    let type: SBKikMessageType
    let body: String
}

public typealias SBKikUser = String
public protocol SBKikMessage: SBMessage {
    var type: SBKikMessageType { get }
    var chatId: String { get }
    var id: String { get }
    var from: SBKikUser { get }
    var participants: [SBKikUser]? { get }
    var timestamp: Int64 { get }
    var mention: String? { get }
    var to: SBKikUser? { get }
}

public protocol SBKikAttribution {
    var name: String { get }
    var iconURL: NSURL { get }
}

public protocol SBKikVideoMessage: SBKikMessage {
    var videoURL: NSURL { get }
    var loop: Bool { get }
    var muted: Bool { get }
    var autoPlay: Bool { get }
    var noSave: Bool { get }
    var attribution: SBKikAttribution { get }
}

public protocol SBKikTextMessage: SBKikMessage {
    var body: String { get }
}

public protocol SBKikPictureMessage: SBKikMessage {
    var pictureURL: NSURL { get }
    var attribution: SBKikAttribution { get }
}

public protocol SBKikMessageSend: SBMessage {
    var type: SBKikMessageType { get }
    var chatId: String { get }
    var to: SBKikUser { get }
    var suggestedResponses: [String]? { get }
}

extension SBKikMessageSend {
    internal func toJSON() -> JSON {
        return [String: AnyObject]()
    }
}

extension SBKikTextMessageSend {
    internal func toJSON() -> JSON {
        return [
            "to": self.to,
            "type": self.type.toString(),
            "body": self.body,
        ]
    }
}

public protocol SBKikTextMessageSend: SBKikMessageSend {
    var body: String { get }
}
