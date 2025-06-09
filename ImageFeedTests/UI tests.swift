@testable import ImageFeed
import Foundation
import XCTest

func testViewControllerDisplaysProfileCorrectly() {
    let viewController = ProfileViewController()
    
    viewController.loadViewIfNeeded()
    
    let profileViewModel = ProfileViewModel(
        name: "Sofya",
        login: "@tarnalitska",
        bio: "Hello, world!"
    )
    
    viewController.show(profile: profileViewModel)
    
    XCTAssertEqual(viewController.fullNameLabel?.text, "Sofya")
    XCTAssertEqual(viewController.accountNameLabel?.text, "@tarnalitska")
    XCTAssertEqual(viewController.descriptionLabel?.text, "Hello, world!")
}

func testViewControllerSetAvatarFromURL() {}

func testViewControllerShowsLogoutAlertWhenLogoutButtonTapped() {}

func testNavigateToSplashSetsRootViewControllerToSplash() {}

// 1 Авторизация в приложение уже тянет на первый тест-кейс!
// 2 Использование ленты
// 3 Разлогин
