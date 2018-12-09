import Foundation

open class Promise<T> {
    public let future: Future<T> = Future()

    public init() {}

    public init(_ handler: (@escaping (T) -> Void, @escaping (NSError) -> Void) -> Void) {
        handler(resolve, reject)
    }

    open func resolve(_ value: T) {
        future.complete(Try<T>(value))
    }

    open func reject(_ error: NSError) {
        future.complete(Try<T>(error))
    }

    public static func resolved(with value: T) -> Promise<T> {
        let promise = Promise<T>()
        promise.resolve(value)
        return promise
    }

    public static func rejected(with error: NSError) -> Promise<T> {
        let promise = Promise<T>()
        promise.reject(error)
        return promise
    }
}
