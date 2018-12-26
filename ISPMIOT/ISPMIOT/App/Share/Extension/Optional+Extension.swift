import UIKit

extension Optional where Wrapped: Collection { 
    var isNilOrEmpty: Bool {
        switch self {
        case .some(let collection):
            return collection.isEmpty
        case .none:
            return true
        }
    }
}

extension Optional where Wrapped == String {
    var unwrappedIfNonNilNonEmpty: String? {
        switch self {
        case .none:
            return nil
        case .some(let wrapped):
            if wrapped.isEmpty {
                return nil
            } else {
                return wrapped
            }
        }
    }
}
