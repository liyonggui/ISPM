import Foundation

extension Future where T: Any {
    public class func when(_ futures: [Future<T>]) -> Future<[Any]> {
        
        let group = DispatchGroup()
        let lock = DispatchQueue(label: "futures queue for resolution checking", attributes: [])
        
        let promise = Promise<[Any]>()
        let futuresCheck = {
            let values = futures.compactMap { (future: Future<T>) -> Any? in
                guard let value = future.value else { return .none }
                switch value {
                case .success(let value): return value
                case .failure(let error): return error
                }
            }
            guard values.count == futures.count else { return }
            DispatchQueue.main.async(execute: { promise.resolve(values) })
        }
        for future in futures {
            future.onComplete { _ in lock.async(group: group) { futuresCheck() } }
        }
        return promise.future
    }
}
