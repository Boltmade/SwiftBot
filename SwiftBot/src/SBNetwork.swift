import Alamofire

enum KikApiRouter: URLRequestConvertible {
    static let baseURLString = "https://api.kik.com/v1"

    case KikConfigure(webHook: String, features: [String: Bool])
    case KikSendMessage(kikMessages: [KikMessageSend])

    var method: Alamofire.Method {
        switch self {
        case .KikConfigure:
            return .POST
        case .KikSendMessage(_):
            return .POST
        }
    }

    var path: String {
        switch self {
        case .KikConfigure(_):
            return "/config"
        case .KikSendMessage(_):
            return "/message"
        }
    }

    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: KikApiRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.timeoutInterval = 3.0
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .KikConfigure(let webHook, let features):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: [
                    "webhook": webHook,
                    "features": features
                ]).0
        case .KikSendMessage(let kikMessages):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: [
                    "messages": kikMessages.map { $0.toJSON() },
                ]).0
        }
    }
}
