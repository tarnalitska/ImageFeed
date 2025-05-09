import UIKit

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let large: String
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidchange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    
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
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let avatarURLString = response.profileImage.large
                    self?.avatarURL = avatarURLString
                    completion(.success(avatarURLString))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURLString]
                        )
                    
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
                    print("[dataTask]: Error while fetching profile image: \(error.localizedDescription)\nResponse: \(responseString)")
                    
                    completion(.failure(error))
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
