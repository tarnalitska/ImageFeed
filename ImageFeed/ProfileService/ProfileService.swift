import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    let urlSession = URLSession.shared
    
    func getProfile() -> Profile? {
        return profile
    }
    
    func fetchProfile(_ authToken: String, completion: @escaping(Result <Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard let request = makeProfileRequest(authToken: authToken) else {
            print("Error: failed to create token request")
            completion(.failure(AppError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let profile = Profile(
                        username: response.username,
                        name: "\(response.firstName) \(response.lastName ?? "")",
                        loginName: "@\(response.username)",
                        bio: response.bio
                    )
                    self.profile = profile
                    
                    completion(.success(profile))
                    
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
                    print("[dataTask]: Error while fetching profile: \(error.localizedDescription)\nResponse: \(responseString)")
                    
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func makeProfileRequest(authToken: String) -> URLRequest? {
        guard let url = URL(
            string: "https://api.unsplash.com/me") else {
            print("Error: url is missing for unsplash profile request")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clearProfile() {
        profile = nil
    }
}

extension ProfileService: ProfileServiceProtocol {}
