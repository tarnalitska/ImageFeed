import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(_ authToken: String, completion: @escaping(Result <Profile, Error>) -> Void)
    func clearProfile()
    func getProfile() -> Profile?
}
