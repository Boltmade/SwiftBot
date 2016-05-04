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
    internal var botUsername: SBKikUser?
    internal var apiKey: String?

    struct IncomingMessageText: SBKikTextMessage {
        var body: String
        var type: SBKikMessageType
        var chatId: String
        var id: String
        var from: SBKikUser
        var participants: [SBKikUser]?
        var timestamp: Int64
        var mention: String?
        var to: SBKikUser?

        init(body: String,
             type: SBKikMessageType,
             chatId: String,
             id: String,
             from: SBKikUser,
             participants: [SBKikUser]?,
             timestamp: Int64,
             mention: String?,
             to: SBKikUser?) {

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
                let from = json["from"] as? SBKikUser,
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
        let responseMessages = responses
            .map { $0.responseMessages }
            .flatten()
        let textMessages = responseMessages.filter { return $0 is SBKikTextMessageSend }

        let json = responses
            .map { $0.responseMessages }
            .flatten()
            .filter { return $0 is SBKikTextMessageSend }
            .map { ($0 as! SBKikTextMessageSend).toJSON() }
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
            message: SBKikMessage) -> SBResponses {
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
}
