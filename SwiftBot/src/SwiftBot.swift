import Foundation

extension String: ErrorType {}

struct SBResult<T> {
    var value: T?
    var error: ErrorType?
}

typealias Handler = (SBResponses, SBMessage) -> SBResponses
public protocol SBHandler {
    func canHandle(incomingMessage: SBMessage) -> Bool
    func handle(responses: SBResponses, incomingMessage: SBMessage) -> SBResponses
}

public typealias JSON = [String: AnyObject]
public class SwiftBot {
    let handlers: [SBHandler]

    public init(handlers: [SBHandler]) {
        self.handlers = handlers
    }

    public func execute(message: JSON) -> [SBResponses] {
        return [SBResponses]()
    }

    public func send(responses: [SBResponses]) {

    }
}

public struct SBResponses {
    public var responseMessages: [SBMessage]

    public init(responseMessages: [SBMessage]) {
        self.responseMessages = responseMessages
    }
}
