import Foundation

extension String: ErrorType {}

struct SBResult<T> {
    var value: T?
    var error: ErrorType?
}

public protocol SBHandler {
    func canHandle(message: SBMessage) -> Bool
    func handle(message: SBMessage)
}

public typealias JSON = [String: AnyObject]
public class SwiftBot {
    let handlers: [SBHandler]

    public init(handlers: [SBHandler]) {
        self.handlers = handlers
    }
}