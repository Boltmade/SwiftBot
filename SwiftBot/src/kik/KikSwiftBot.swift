import Foundation

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

    override public func send(responses: [SBResponses]) {
        let responseMessages = responses
            .map { $0.responseMessages }
            .flatten()

        let messages = responseMessages
            .filter {
                return $0 is SBKikMessage && ($0 as! SBKikMessage).canSend()
            }
            .map { ($0 as! SBKikMessage).toJSON() }

        if messages.count > 0 {
            do {
                try self.sendMessages(messages)
            } catch let e {
                print("Error: \(e)")
            }
        }
    }

    override public func execute(message: JSON) -> [SBResponses] {

        func recursiveHandle(
            responses: SBResponses,
            handlers: [SBHandler],
            message: SBKikMessage) -> SBResponses {
                var handlers = handlers
                var responses = responses
            if handlers.count > 0 {
                let handler = handlers.removeFirst()
                if handler.canHandle(responses, incomingMessage: message) {
                    responses = recursiveHandle(handler.handle(responses, incomingMessage: message), handlers: handlers, message: message)
                }
                return recursiveHandle(responses, handlers: handlers, message: message)
            }
            return responses
        }

        // Execute Chain
        let supportedMessageTypes = [
            SBKikMessageType.Text.toString(),
            SBKikMessageType.Picture.toString(),
            SBKikMessageType.Video.toString(),
            SBKikMessageType.ScanData.toString(),
            SBKikMessageType.Link.toString()
        ]
        if let messages = message["messages"] as? [JSON] {
            let responses = SBResponses(responseMessages: [])
            let incomingMessages = messages
                .filter {
                    return ($0["type"] as? String) != nil &&
                        supportedMessageTypes.contains(($0["type"] as! String))
                }
                .map {
                    switch ($0["type"] as! String) {
                    case "text":
                        return SBKikTextMessage.messageWith($0)
                    case "picture":
                        return SBKikPictureMessage.messageWith($0)
                    case "video":
                        return SBKikVideoMessage.messageWith($0)
                    case "scan-data":
                        return SBKikScanDataMessage.messageWith($0)
                    default:
                        return nil
                    }
                }
                .filter { $0 != nil }
                .map { $0! }
                .map { recursiveHandle(responses, handlers: self.handlers, message: $0) }
            return incomingMessages
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

        let request = KikApiRouter
            .KikSendMessage(kikMessages: kikMessages)
            .URLRequest
            .authenticate(config.username, password: config.key)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200 {
                print("Send message failed: \(error)")
            } else {
                print("Send message failed: \(error)")
            }
        }
        task.resume()
    }

    public func kikConfigure(username: String, APIKey: String, webHook: String) {

        let features = [
            "manuallySendReadReceipts": false,
            "receiveReadReceipts": false,
            "receiveDeliveryReceipts": false,
            "receiveIsTyping": false
        ]
        let request = KikApiRouter
            .KikConfigure(webHook: webHook, features: features)
            .URLRequest
            .authenticate(username, password: APIKey)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200 {
                self.successfulConfig = true
                self.botUsername = username
                self.apiKey = APIKey
                print("Kik Bot successfully configured")
            } else {
                print("Kik Bot configuration failed: \(error)")
            }
        }
        task.resume()
    }
}
