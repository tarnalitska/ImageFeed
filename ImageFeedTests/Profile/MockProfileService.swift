@testable import ImageFeed
import Foundation
import XCTest

final class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
    
    func fetchProfile(_ authToken: String, completion: @escaping (Result<ImageFeed.Profile, any Error>) -> Void) {
        
    }
    
    func clearProfile() {
        profile = nil
    }
    
    func getProfile() -> ImageFeed.Profile? {
        return Profile(
            username: "tarnalitska",
            name: "Sofya Tarnalitskaya",
            loginName: "@tarnalitska",
            bio: "Hello, world!")
    }
}

