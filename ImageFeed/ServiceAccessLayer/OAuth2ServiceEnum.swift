import Foundation

enum OAuth2Error: Error {
    case invalidRequest
    case noData
    case httpStatusError(Int, String?)
    case decodingError(Error)
    case networkError(Error)
}

enum HTTPMethod: String {
    case post = "POST"
}
