import UIKit

final class OAuth2Service {
    struct OAuthTokenResponse: Decodable {
        let accessToken: String
    }
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    let tokenStorage = OAuth2TokenStorage()
    
    static let shared = OAuth2Service()
    private init () {}
    
    func fetchOAuthToken(code: String, completion: @escaping(Result <String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AppError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        if let token = tokenStorage.token {
            completion(.success(token))
            return
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error: failed to create token request")
            completion(.failure(AppError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let token = response.accessToken
                    self?.tokenStorage.token = token
                    print("✅ Token saved to UserDefaults: \(token)")
                    completion(.success(token))
                case .failure(let error):
                    var responseString = ""
                    
                    if let appError = error as? AppError {
                        switch appError {
                        case .httpStatusError(let code, let data):
                            responseString = String(data: data, encoding: .utf8) ?? "[dataTask]: Unable to decode response data, code: \(code)"
                        default:
                            break
                        }
                    }
                    print("[dataTask]: Error while fetching OAuth token: \(error.localizedDescription)\nResponse: \(responseString)")
                    
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastCode = nil
            }
            
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Error: Base url is missing for unsplash login")
            return nil
        }
        
        let urlString =
        "oauth/token" +
        "?client_id=\(Constants.accessKey)" +
        "&&client_secret=\(Constants.secretKey)" +
        "&&redirect_uri=\(Constants.redirectURI)" +
        "&&code=\(code)" +
        "&&grant_type=authorization_code"
        
        guard let url = URL(
            string: urlString, relativeTo: baseURL) else {
            print("Error: Url components are missing for unsplash login")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = SnakeCaseJSONDecoder()
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    if T.self == EmptyResponse.self && data.isEmpty {
                        completion(.success(EmptyResponse() as! T))
                        return
                    }
                    
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(AppError.decodingError(error)))
                }
            case .failure(let error):
                print("Data error: \(error)")
                completion(.failure(error))
            }
        }
        return task
    }
    
    
    func data(
        for request: URLRequest,
        completion: @escaping(Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = ( response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(
                        .failure(AppError.httpStatusError(statusCode: statusCode, data: data)))
                    print("dataTask error: \(statusCode)\nResponse: \(data)")
                }
            } else if let error = error {
                print("dataTask request error: \(error)")
                fulfillCompletionOnTheMainThread(.failure(AppError.urlRequestError(error)))
            } else {
                print("dataTask url session error")
                fulfillCompletionOnTheMainThread(.failure(AppError.urlSessionError))
            }
        })
        
        return task
    }
}
