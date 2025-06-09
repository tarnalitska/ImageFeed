@testable import ImageFeed
import Foundation
import XCTest

final class MockProfileImageService: ProfileImageServiceProtocol {
    static let didChangeNotification = Notification.Name("MockProfileImageServiceDidChange")
    
    var avatarURL: String? = "https://mock/avatar.png"
    
    func postNotification() {
        let userInfo = ["URL": avatarURL as Any]
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self, userInfo: userInfo)
    }
}
