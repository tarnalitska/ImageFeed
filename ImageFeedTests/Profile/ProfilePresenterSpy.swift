@testable import ImageFeed
import Foundation
import XCTest

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled: Bool = false
    var confirmLogoutCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func confirmLogout() {
        confirmLogoutCalled = true
    }
}
