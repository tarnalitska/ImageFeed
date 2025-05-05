import UIKit

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidchange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, completion: @escaping(Result <String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard let authToken = storage.token else  {
            print("Error: failed to create token request")
            completion(.failure(AppError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(authToken: authToken) else {
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
                    print("Error: no data received from profile request")
                    DispatchQueue.main.async {
                        completion(.failure(AppError.noData))
                    }
                    return
                }
                
                do {
                    let decoder = SnakeCaseJSONDecoder()
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    
                    let avatarURLString = userResult.profileImage.small
                    self?.avatarURL = avatarURLString
    
                    completion(.success(avatarURLString))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURLString]
                        )
                    
                } catch {
                    print("JSON parsing error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(AppError.decodingError(error)))
                    }
                }
            }
        }
        task.resume()
    }
    
    func makeProfileImageRequest(authToken: String) -> URLRequest? {
        guard let url = URL(
            string: "https://api.unsplash.com/me") else {
            print("Error: url is missing for unsplash profile image request")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
