@testable import ImageFeed
import Foundation
import XCTest

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var loadNextPageCalled = false
    var changeLikeCalledWith: (photoId: String, isLike: Bool)?
    var changeLikeCompletion: ((Result<Void, Error>) -> Void)?
    
    func loadNextPage(_ token: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        loadNextPageCalled = true
        completion?(.success(()))
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalledWith = (photoId, isLike)
        changeLikeCompletion = completion
    }
    
    static var didChangeNotification: Notification.Name {
        return Notification.Name("ImagesListServiceMockDidChange")
    }
}
