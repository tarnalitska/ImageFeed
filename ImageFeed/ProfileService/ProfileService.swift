import UIKit

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ authToken: String, completion: @escaping(Result <Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard let request = makeProfileRequest(authToken: authToken) else {
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
                    
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)
                    
                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName) \(profileResult.lastName)",
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                    )
    
                    completion(.success(profile))
                    
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
    
}
