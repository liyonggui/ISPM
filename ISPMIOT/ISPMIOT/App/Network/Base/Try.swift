import Foundation

public enum Try<T> {
    case success(T)
    case failure(NSError)

    public init(_ value: T) {
        self = .success(value)
    }

    public init(_ error: NSError) {
        self = .failure(error)
    }

    public func map<U>(_ f: (T) -> U) -> Try<U> {
        switch self {
        case .success(let value):
            return .success(f(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    public func flatMap<U>(_ f:(T) -> Try<U>) -> Try<U> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
