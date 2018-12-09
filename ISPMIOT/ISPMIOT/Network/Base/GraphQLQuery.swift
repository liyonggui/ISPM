import Foundation

public struct GraphQLQuery {
    let namedQuery: String
    let queryType: String
    let fields: [GraphQLField]
    let variables: [String: Any]

    public init(namedQuery: String,
         queryType: String,
         fields: [GraphQLField],
         variables: [String: Any]) {
        self.namedQuery = namedQuery
        self.queryType = queryType
        self.fields = fields
        self.variables = variables
    }

    var querySet: String {
        var query = "{"
        fields.forEach { query += $0.request }
        query += " }"
        return query
    }

    public var body: [String: Any] {
        let query = "\(namedQuery) { \(queryType) \(querySet) }"
        return [
            "query": query,
            "variables": variables
        ]
    }
}


public indirect enum GraphQLField {
    case field(String)
    case collection((field: String, items: [GraphQLField]))

    var request: String {
        switch self {
        case .field(let tag):
            return " \(tag)"
        case .collection(let collection):
            var tagString = " \(collection.field) { "
            collection.items.forEach { tagString += $0.request }
            tagString += " }"
            return tagString
        }
    }
}
