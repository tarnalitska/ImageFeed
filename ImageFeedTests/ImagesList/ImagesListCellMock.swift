@testable import ImageFeed
import Foundation
import XCTest
import Foundation

final class ImagesListCellMock: ImagesListCellProtocol {
    var dateLabelText: String?
    private(set) var isLikedSet: Bool?
    private(set) var imageSetURL: URL?
    private(set) var imageSetPlaceholder: UIImage?
    
    func setIsLiked(_ isLiked: Bool) {
        isLikedSet = isLiked
    }
    
    func setImage(with url: URL?, placeholder: UIImage?) {
        imageSetURL = url
        imageSetPlaceholder = placeholder
    }
}
