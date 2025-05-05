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
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: network error")
                    DispatchQueue.main.async {
                        completion(.failure(AppError.networkError(error)))
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    
                    print("Error: Unsplash service error — status: \(httpResponse.statusCode)")
                    
                    var errorBody: String?
                    
                    if let data = data {
                        errorBody = String(data: data, encoding: .utf8)
                        print("Response body: \(String(describing: errorBody))")
                    }
                    
                    completion(.failure(AppError.httpStatusError(httpResponse.statusCode, errorBody)))
                }
                
                guard let data = data else {
                    print("Error: no data received from token request")
                    DispatchQueue.main.async {
                        completion(.failure(AppError.noData))
                    }
                    return
                }
                
                
                do {
                    let decoder = SnakeCaseJSONDecoder()
                    
                    let response = try decoder.decode(OAuthTokenResponse.self, from: data)
                    let token = response.accessToken
                    
                    self?.tokenStorage.token = token
                    print("✅ Token saved to UserDefaults: \(token)")
                    
                    DispatchQueue.main.async {
                        completion(.success(response.accessToken))
                    }
                    
                } catch {
                    print("Decoding error: \(error) ")
                    DispatchQueue.main.async {
                        completion(.failure(AppError.decodingError(error)))
                    }
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
