@testable import ImageFeed
import Foundation
import XCTest

final class ImagesListViewMock: ImagesListViewProtocol {
    var updatePhotosCalled = false
    var reloadTableCalled = false
    var insertRowsCalledAt: [IndexPath]?
    var reloadRowCalledAt: IndexPath?
    var navigateToSingleImageScreenCalledWithURL: URL?
    
    func updatePhotos(_ photos: [Photo]) {
        updatePhotosCalled = true
    }
    func reloadTable() {
        reloadTableCalled = true
    }
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalledAt = indexPaths
    }
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalledAt = indexPath
    }
    func navigateToSingleImageScreen(with url: URL) {
        navigateToSingleImageScreenCalledWithURL = url
    }
}

