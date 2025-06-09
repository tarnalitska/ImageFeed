@testable import ImageFeed
import Foundation
import XCTest

final class ProfileViewViewControllerSpy: ProfileViewControllerProtocol {
    var updatedAvatarURL: URL?
    var showProfileCalled = false
    var navitatedToSplash = false
    var receivedViewModel: ProfileViewModel?
    
    var presenter: (any ImageFeed.ProfilePresenterProtocol)?
    
    func show(profile: ProfileViewModel) {
        showProfileCalled = true
        receivedViewModel = profile
    }
    
    func updateAvatar(with url: URL) {
        updatedAvatarURL = url
    }
    
    func showLogoutAlert() {
        
    }
    
    func navigateToSplash() {
        navitatedToSplash = true
    }
}
