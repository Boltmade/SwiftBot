public enum SBKikMessageType {
    case Text
    case Picture
    case Video
    case Link

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
            SBKikSuggestedResponse(body: $0)
        }
    }

    func jsonSerialize() -> JSON {
        return JSON()
    }
}

internal struct SBKikSuggestedResponse {
    let type: String = "text"
    let body: String

    func jsonSerialize() -> JSON {
        return [
                "type": self.type,
                "body": self.body
                ]
    }
}

public typealias SBKikUser = String

public protocol SBKikAttribution {
    var name: String { get }
    var iconUrl: String { get }
}

public protocol SBKikMessage: SBMessage {
    var type: SBKikMessageType { get }
    var chatId: String? { get }
    var id: String? { get }
    var from: SBKikUser? { get }
    var participants: [SBKikUser]? { get }
    var timestamp: Int? { get }
    var mention: String? { get }
    var to: SBKikUser? { get }

    func jsonSerialize() -> JSON
    func canSend() -> Bool
}

public struct SBKikVideoMessage: SBKikMessage {
    //SBKIKMESSAGE PROTOCOL
    public var type: SBKikMessageType = .Video
    public var chatId: String?
    public var id: String?
    public var from: SBKikUser?
    public var participants: [SBKikUser]?
    public var timestamp: Int?
    public var mention: String?
    public var to: SBKikUser?

    //VIDEO SPECIFIC
    public var videoUrl: String
    public var loop: Bool?
    public var muted: Bool?
    public var autoplay: Bool?
    public var noSave: Bool?
    public var attribution: SBKikAttribution?

    //OVERRIDE PROTOCOL METHODS
    public func canSend() -> Bool {
        return self.to != nil
    }

    public func jsonSerialize() -> JSON {
        return [
            "to": self.to == nil ? "" : self.to!,
            "type": self.type.toString(),
            "videoUrl": self.videoUrl
        ]
    }

    static func messageWith(json: JSON) -> SBKikMessage? {
        guard let type = json["type"] as? String
            where type == "video" else {
                return nil
        }

        if let chatId = json["chatId"] as? String,
            let id = json["id"] as? String,
            let typeString = json["type"] as? String,
            let from = json["from"] as? SBKikUser,
            let pictureUrl = json["picUrl"] as? String,
            let timestampAny = json["timestamp"] as? Int,
            let videoUrl = json["videoUrl"] as? String,
            let loop = json["loop"] as? Bool,
            let muted = json["muted"] as? Bool,
            let autoplay = json["autoplay"] as? Bool,
            let noSave = json["noSave"] as? Bool {

            return SBKikVideoMessage(
                chatId: chatId,
                id: id,
                from: from,
                participants: nil,
                timestamp: timestampAny,
                mention: nil,
                to: nil,
                videoUrl: videoUrl,
                loop: loop,
                muted: muted,
                autoplay: autoplay,
                noSave: noSave,
                attribution: nil)
        }
        return nil
    }

    public init(
        chatId: String? = nil,
        id: String? = nil,
        from: SBKikUser? = nil,
        participants: [SBKikUser]? = nil,
        timestamp: Int? = nil,
        mention: String? = nil,
        to: SBKikUser? = nil,
        videoUrl: String,
        loop: Bool? = nil,
        muted: Bool? = nil,
        autoplay: Bool? = nil,
        noSave: Bool? = nil,
        attribution: SBKikAttribution? = nil) {

        self.chatId = chatId
        self.id = id
        self.from = from
        self.participants = participants
        self.timestamp = timestamp
        self.mention = mention
        self.to = to
        self.videoUrl = videoUrl
        self.loop = loop
        self.muted = muted
        self.autoplay = autoplay
        self.noSave = noSave
        self.attribution = attribution
    }
}

public struct SBKikTextMessage: SBKikMessage {
    //SBKIKMESSAGE PROTOCOL
    public var type: SBKikMessageType = .Text
    public var chatId: String?
    public var id: String?
    public var from: SBKikUser?
    public var participants: [SBKikUser]?
    public var timestamp: Int?
    public var mention: String?
    public var to: SBKikUser?

    //TEXT SPECIFIC
    public var body: String

    public init(
        chatId: String? = nil,
        id: String? = nil,
        from: SBKikUser? = nil,
        participants: [SBKikUser]? = nil,
        timestamp: Int? = nil,
        mention: String? = nil,
        to: SBKikUser? = nil,
        body: String) {

        self.chatId = chatId
        self.id = id
        self.from = from
        self.participants = participants
        self.timestamp = timestamp
        self.mention = mention
        self.to = to
        self.body = body
    }

    //OVERRIDE PROTOCOL METHOD
    public func canSend() -> Bool {
        return self.to != nil
    }

    public func jsonSerialize() -> JSON {
        return [
            "to": self.to == nil ? "" : self.to!,
            "type": self.type.toString(),
            "body": self.body
        ]
    }

    static func messageWith(json: JSON) -> SBKikMessage? {
        guard let type = json["type"] as? String
            where type == "text" else {
                return nil
        }

        if let chatId = json["chatId"] as? String,
            let id = json["id"] as? String,
            let typeString = json["type"] as? String,
            let from = json["from"] as? SBKikUser,
            let body = json["body"] as? String,
            let timestampAny = json["timestamp"] as? Int {

            return SBKikTextMessage(
                chatId: chatId,
                id: id,
                from: from,
                participants: nil,
                timestamp: timestampAny,
                mention: nil,
                to: nil,
                body: body)
        }
        return nil
    }
}

public struct SBKikPictureMessage: SBKikMessage {
    //SBKIKMESSAGE PROTOCOL
    public var type: SBKikMessageType = .Picture
    public var chatId: String?
    public var id: String?
    public var from: SBKikUser?
    public var participants: [SBKikUser]?
    public var timestamp: Int?
    public var mention: String?
    public var to: SBKikUser?

    //PICTURE SPECIFIC
    public var attribution: SBKikAttribution?
    var pictureUrl: String

    //OVERRIDE PROTOCOL METHOD
    public func canSend() -> Bool {
        return self.to != nil
    }

    public func jsonSerialize() -> JSON {
        return [
            "to": self.to == nil ? "" : self.to!,
            "type": self.type.toString(),
            "picUrl": self.pictureUrl
        ]
    }

    static func messageWith(json: JSON) -> SBKikMessage? {
        guard let type = json["type"] as? String
            where type == "picture" else {
                return nil
        }

        if let chatId = json["chatId"] as? String,
            let id = json["id"] as? String,
            let typeString = json["type"] as? String,
            let from = json["from"] as? SBKikUser,
            let pictureUrl = json["picUrl"] as? String,
            let timestampAny = json["timestamp"] as? Int {

            return SBKikPictureMessage(
                chatId: chatId,
                id: id,
                from: from,
                participants: nil,
                timestamp: timestampAny,
                mention: nil,
                to: nil,
                attribution: nil,
                pictureUrl: pictureUrl)
        }
        return nil
    }

    public init(
        chatId: String? = nil,
        id: String? = nil,
        from: SBKikUser? = nil,
        participants: [SBKikUser]? = nil,
        timestamp: Int? = nil,
        mention: String? = nil,
        to: SBKikUser? = nil,
        attribution: SBKikAttribution? = nil,
        pictureUrl: String) {

        self.chatId = chatId
        self.id = id
        self.from = from
        self.participants = participants
        self.timestamp = timestamp
        self.mention = mention
        self.to = to
        self.attribution = attribution
        self.pictureUrl = pictureUrl
    }
}

extension SBKikMessage {
    func messageWith(json: JSON) -> SBKikMessage? {
        return nil
    }
}
