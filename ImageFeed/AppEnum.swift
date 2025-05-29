import Foundation

enum AppError: Error {
    case invalidRequest
    case noData
    case httpStatusError(statusCode: Int, data: Data)
    case decodingError(Error)
    case networkError(Error)
    case urlRequestError(Error)
    case urlSessionError
}

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}
