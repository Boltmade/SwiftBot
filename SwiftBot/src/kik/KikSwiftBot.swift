import Foundation
import Alamofire

internal let KikUsername = "KikUsernameKey"
internal let KikAPIKey = "KikUsernameKey"
typealias SBKikConfig = (username: String, key: String)

enum KikError: ErrorType {
    case BadConfifguration
}

public class KikSwiftBot: SwiftBot {

    private(set) public var successfulConfig = false
    internal var botUsername: KikUser?
    internal var apiKey: String?

    struct IncomingMessageText: KikTextMessage {
        var body: String
        var type: KikMessageType
        var chatId: String
        var id: String
        var from: KikUser
        var participants: [KikUser]?
        var timestamp: Int64
        var mention: String?
        var to: KikUser?

        init(body: String,
             type: KikMessageType,
             chatId: String,
             id: String,
             from: KikUser,
             participants: [KikUser]?,
             timestamp: Int64,
             mention: String?,
             to: KikUser?) {

                self.body = body
                self.type = type
                self.chatId = chatId
                self.id = id
                self.from = from
                self.participants = participants
                self.timestamp = timestamp
                self.mention = mention
                self.to = to
        }

        static func messageWith(json: JSON) -> IncomingMessageText? {
            if let chatId = json["chatId"] as? String,
                let id = json["id"] as? String,
                let typeString = json["type"] as? String,
                let from = json["from"] as? KikUser,
                let body = json["body"] as? String,
                let timestampAny = json["timestamp"] as? Int
                 where typeString == "text" {

                    return IncomingMessageText(
                        body: body,
                        type: .Text,
                        chatId: chatId,
                        id: id,
                        from: from,
                        participants: nil,
                        timestamp: Int64(timestampAny),
                        mention: nil,
                        to: nil)
            }
            return nil
        }
    }

    override public func send(responses: [SBResponses]) {
        let json = responses
            .map { $0.responseMessages }
            .flatten()
            .filter { return $0 is KikTextMessageSend }
            .map { ($0 as! KikTextMessageSend).toJSON() }
        if json.count > 0 {
            do {
                try self.sendMessages(json)
            } catch let e {
                print("Error: \(e)")
            }
        }
    }

    override public func execute(message: JSON) -> [SBResponses] {

        func something(
            responses: SBResponses,
            handlers: [SBHandler],
            message: KikMessage) -> SBResponses {
                var handlers = handlers
                if handlers.count > 0 {
                    let handler = handlers.removeFirst()
                    return something(handler.handle(responses, incomingMessage: message), handlers: handlers, message: message)
                } else {
                    return responses
                }
        }

        // Execute Chain
        if let messages = message["messages"] as? [JSON] {
            let responses = SBResponses(responseMessages: [])
            let textMessageResponses = messages
                .filter{ ($0["type"] as? String) == "text" }
                .map{ IncomingMessageText.messageWith($0) }
                .filter{ $0 != nil }
                .map{ $0! }
                .map{ something(responses, handlers: self.handlers, message: $0) }
            return textMessageResponses
        }
        return [SBResponses]()
    }
}

extension KikSwiftBot {

    internal func configuredGuard() -> SBResult<SBKikConfig> {
        if let username = self.botUsername,
            let key = self.apiKey {
            return SBResult<SBKikConfig>(value: (username, key), error: nil)
        }
        return SBResult<SBKikConfig>(value: nil, error: "Bot not configured")
    }

    internal func sendMessages(kikMessages: [JSON]) throws {
        let configResult = configuredGuard()
        guard let config = configResult.value else {
            print(configResult.error)
                throw KikError.BadConfifguration
        }

        Alamofire
            .request(KikApiRouter.KikSendMessage(kikMessages: kikMessages))
            .authenticate(user: config.username, password: config.key)
            .validate()
            .responseJSON() { (firedResponse) -> Void in
                if let error = firedResponse.result.error {
                    print("Send message failed: \(error)")
                } else {
                    print("Successful send")
                }
        }
    }

    public func kikConfigure(username: String, APIKey: String, webHook: String) {

        KikSwiftBot.setUsername(username, APIKey: APIKey)
        Alamofire
            .request(KikApiRouter.KikConfigure(
                webHook: webHook,
                features: [
                    "manuallySendReadReceipts": false,
                    "receiveReadReceipts": false,
                    "receiveDeliveryReceipts": false,
                    "receiveIsTyping": false
                ]))
            .authenticate(user: username, password: APIKey)
            .validate()
            .responseJSON() { (firedResponse) -> Void in
                if let error = firedResponse.result.error {
                    print("Kik Bot configuration failed: \(error)")
                } else {
                    self.successfulConfig = true
                    self.botUsername = username
                    self.apiKey = APIKey
                    print("Kik Bot successfully configured")
                }
            }
    }

    internal static func setUsername(username: String, APIKey: String) {
        NSUserDefaults.standardUserDefaults()
            .setObject(username, forKey: KikUsername)
        NSUserDefaults.standardUserDefaults()
            .setObject(APIKey, forKey: KikAPIKey)
    }
}
