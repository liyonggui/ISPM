import Foundation

open class Future<T> {
    
    var _value: Try<T>?
    var _isCompleted = false
    
    var successCallbacks: Array<(T) -> Void> = []
    var failureCallbacks: Array<(NSError) -> Void> = []
    var completeCallbacks: Array<(Try<T>) -> Void> = []

    internal init() {}
    
    public convenience init(f: @escaping () -> Try<T>) {
        self.init(queue: OperationQueue.main, f: f)
    }
    
    public init(queue: OperationQueue, f: @escaping () -> Try<T>) {
        queue.addOperation() {
            self.complete(f())
        }
    }

    public static func retrying(count: Int = 1, f: @escaping () -> Future<T>) -> Future<T> {
        var future = f()

        for i in 0..<count {
            future = future
                .flatMapTry { result in
                    switch result {
                    case .success(let value):
                        return Promise<T>.resolved(with: value).future
                    case .failure:
                        // exponential backoff with a maximum retry interval of 10 seconds
                        let delay = min(10, pow(2, Double(i + 1)))

                        return Promise<T> { resolve, reject in
                            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                                f().onComplete { result in
                                    switch result {
                                    case .failure(let error):
                                        reject(error)
                                    case .success(let value):
                                        resolve(value)
                                    }
                                }
                            }
                        }
                        .future
                    }
                }
        }

        return future
    }
    
    open var value: Try<T>? {
        get {
            return _value
        }
    }
    
    open var isCompleted: Bool {
        get {
            return _isCompleted
        }
    }
    
    open func onComplete(_ callback: @escaping (Try<T>) -> Void) {
        if isCompleted {
            callback(value!)
        } else {
            completeCallbacks.append(callback)
        }
    }
    
    open func onSuccess(_ callback: @escaping (T) -> Void) {
        if isCompleted {
            if let v = value {
                switch(v) {
                case .success(let value):
                    callback(value)
                default:
                    break;
                }
            }
        } else {
            successCallbacks.append(callback)
        }
    }
    
    open func onFailure(_ callback: @escaping (NSError) -> Void) {
        if isCompleted {
            if let v = value {
                switch(v) {
                case .failure(let error):
                    callback(error)
                default:
                    break;
                }
            }
        } else {
            failureCallbacks.append(callback)
        }
    }
    
    open func cancel() {
        successCallbacks = []
        failureCallbacks = []
        completeCallbacks = []
        complete(.failure(NSError(domain: "Cancelled", code: 0, userInfo: nil)))
    }
    
    open func map<U>(_ transform: @escaping (T) -> Try<U>) -> Future<U> {
        let future = Future<U>()
        
        onComplete() { (v) in
            future.complete(v.flatMap(transform))
        }
        return future
    }
    
    open func mapTry<U>(_ transform: @escaping (Try<T>) -> Try<U>) -> Future<U> {
        let promise = Future<U>()
        
        onComplete({ (v: Try<T>) -> Void in
            promise.complete(transform(v))
        })
        return promise
    }
    
    open func flatMap<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        let future = Future<U>()
        
        onComplete() { (v) in
            let newFuture = self.buildFlatMapFuture(v, transform: transform)
            newFuture.onComplete() { (v) in
                future.complete(v)
            }
        }
        return future
    }
    
    open func flatMapTry<U>(_ transform: @escaping (Try<T>) -> Future<U>) -> Future<U> {
        let future = Future<U>()
        
        onComplete() { (v1) in
            let newFuture = transform(v1)
            newFuture.onComplete() { (v2) in
                future.complete(v2)
            }
        }
        return future
    }
    
    internal func complete(_ value: Try<T>) {
        if isCompleted {
            return
        }
            
        _isCompleted = true
        _value = value
        switch (value) {
        case .success(let value):
            for callback in successCallbacks {
                callback(value)
            }
        case .failure(let error):
            for callback in failureCallbacks {
                callback(error)
            }
        }
        for callback in completeCallbacks {
            callback(self.value!)
        }
        successCallbacks.removeAll(keepingCapacity: false)
        failureCallbacks.removeAll(keepingCapacity: false)
        completeCallbacks.removeAll(keepingCapacity: false)
    }
    
    fileprivate func buildFlatMapFuture<U>(_ v: Try<T>, transform: (T) -> Future<U>) -> Future<U> {
        switch v {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            let newFuture = Future<U>()
            newFuture.complete(Try(error))
            return newFuture
        }
    }
}
