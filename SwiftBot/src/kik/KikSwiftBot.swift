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
}

extension KikSwiftBot {

    internal func configuredGuard() -> SBResult<SBKikConfig> {
        if let username = self.botUsername,
            let key = self.apiKey {
            return SBResult<SBKikConfig>(value: (username, key), error: nil)
        }
        return SBResult<SBKikConfig>(value: nil, error: "Bot not configured")
    }

    public func sendMessage(kikMessage: KikMessageSend) throws {
        let configResult = configuredGuard()
        guard let config = configResult.value else {
            print(configResult.error)
                throw KikError.BadConfifguration
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
