@testable import ImageFeed
import Foundation
import XCTest

final class OAuth2TokenStorageMock: OAuth2TokenStorageProtocol {
    var token: String? = nil
}
