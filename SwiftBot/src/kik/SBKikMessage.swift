public enum KikMessageType {
    case Text
    case Picture
    case Video
    case Link
    case StartChatting
    case ScanData
    case Sticker
}

public enum KikKeyboardType {
    case Suggested
}

internal struct KikKeyboard {
    let keyboardType: KikKeyboardType = .Suggested
    let responses: [KikResponse]

    init(suggestedResponses: [String]) {
        self.responses = suggestedResponses.map {
            KikResponse(type: .Text, body: $0)
        }
    }
}

internal struct KikResponse {
    let type: KikMessageType
    let body: String
}

public typealias KikUser = String
public protocol KikMessage: SBMessage {
    var type: KikMessageType { get }
    var chatID: String { get }
    var id: String { get }
    var from: KikUser { get }
    var participants: [KikUser] { get }
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

public protocol KikMessageSend: KikMessage {
    var chatID: String? { get }
    var id: String? { get }
    var from: KikUser? { get }
    var participants: [KikUser]? { get }
    var timestamp: Int64? { get }
    var to: KikUser { get }
    var suggestedResponses: [String]? { get }
    func toJSON() -> JSON
}

public protocol KikTextMessageSend: KikMessageSend {
    var body: String { get }
}
