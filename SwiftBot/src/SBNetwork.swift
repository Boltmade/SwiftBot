import Alamofire

enum KikApiRouter: URLRequestConvertible {
    static let baseURLString = "https://api.kik.com/v1"

    case KikConfigure(webHook: String, features: [String: Bool])
    case KikSendMessage(kikMessages: [JSON])

    var method: String {
        switch self {
        case .KikConfigure:
            return "POST"
        case .KikSendMessage(_):
            return "POST"
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

    var HTTPBody: NSData? {
        switch self {
        case .KikConfigure(let params):
            let params = [
                "webhook": params.webHook,
                "features": params.features
            ]
            do {
                return try NSJSONSerialization
                    .dataWithJSONObject(params, options: .PrettyPrinted)
            } catch {
                return nil
            }
        default:
            return nil
        }
    }

    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: KikApiRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.timeoutInterval = 5
        mutableURLRequest.HTTPMethod = method

        switch self {
        case .KikConfigure(_):
            mutableURLRequest.HTTPBody = self.HTTPBody
            return mutableURLRequest
        case .KikSendMessage(let kikMessages):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters:
                [
                    "messages": kikMessages
                ]).0
        }
    }
}

extension NSMutableURLRequest {
    func authenticate(username: String, password: String) -> NSMutableURLRequest {
        let authStr = "\(username):\(password)"
        let authData = authStr.dataUsingEncoding(NSUTF8StringEncoding)
        let header = "Basic \(authData?.base64EncodedDataWithOptions(.EncodingEndLineWithCarriageReturn)))"
        self.setValue(header, forHTTPHeaderField: "Authorization")
        return self
    }
}
