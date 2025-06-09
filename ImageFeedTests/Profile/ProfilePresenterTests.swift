@testable import ImageFeed
import Foundation
import XCTest

final class ProfilePresenterTests: XCTestCase {
    func testPresenterNotifiesViewToUpdateAvatarWithCorrectURL() {
        let viewController = ProfileViewViewControllerSpy()
        let mockProfileService = MockProfileService()
        let mockProfileImageService = MockProfileImageService()
        let presenter = ProfilePresenter(
            view: viewController,
            profileService: mockProfileService,
            profileImageService: mockProfileImageService
        )
        
        presenter.subscribetoAvatarUpdates()
        mockProfileImageService.postNotification()
        
        XCTAssertEqual(viewController.updatedAvatarURL?.absoluteString, mockProfileImageService.avatarURL)
    }
    
    func testPresenterShowProfileOnViewDidLoad() {
        let viewController = ProfileViewViewControllerSpy()
        let mockProfileService = MockProfileService()
        let mockProfileImageService = MockProfileImageService()
        let presenter = ProfilePresenter(
            view: viewController,
            profileService: mockProfileService,
            profileImageService: mockProfileImageService
        )
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.showProfileCalled)
        XCTAssertEqual(viewController.receivedViewModel?.name, "Sofya Tarnalitskaya")
        XCTAssertEqual(viewController.receivedViewModel?.login, "@tarnalitska")
        XCTAssertEqual(viewController.receivedViewModel?.bio, "Hello, world!")
    }
    
    func testViewDidLoadCalledOnViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter: presenter)
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogoutButtonTapCallsDidTapLogout() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter: presenter)
        viewController.loadViewIfNeeded()
        
        guard let logoutButton = viewController.logoutButton else {
            XCTFail("logoutButton is nil")
            return
        }
        logoutButton.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
}
