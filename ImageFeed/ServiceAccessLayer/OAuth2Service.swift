import UIKit

final class OAuth2Service {
    struct OAuthTokenResponse: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    enum OAuth2Error: Error {
        case invalidRequest
        case noData
        case httpStatusError(Int, String?)
        case decodingError(Error)
        case networkError(Error)
    }
    
    static let shared = OAuth2Service()
    init () {}
    
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
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
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping(Result <String, Error>) -> Void) {
        
        if let token = tokenStorage.token {
            completion(.success(token))
            return
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error: failed to create token request")
            completion(.failure(OAuth2Error.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: network error")
                DispatchQueue.main.async {
                    completion(.failure(OAuth2Error.networkError(error)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                
                print("Error: Unsplash service error — status: \(httpResponse.statusCode)")
                
                var errorBody: String? = nil
                if let data = data {
                    errorBody = String(data: data, encoding: .utf8)
                    print("Response body: \(String(describing: errorBody))")
                }
                
                completion(.failure(OAuth2Error.httpStatusError(httpResponse.statusCode, errorBody)))
            }
            
            
            guard let data = data else {
                print("Error: no data received from token request")
                DispatchQueue.main.async {
                    completion(.failure(OAuth2Error.noData))
                }
                return
            }
            
            
            do {
                let response = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
                let token = response.accessToken
                
                self.tokenStorage.token = token
                print("✅ Token saved to UserDefaults: \(token)")
                
                DispatchQueue.main.async {
                    completion(.success(response.accessToken))
                }
                
            } catch {
                print("Decoding error: \(error) ")
                DispatchQueue.main.async {
                    completion(.failure(OAuth2Error.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
}
