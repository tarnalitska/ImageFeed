@testable import ImageFeed
import Foundation
import XCTest

final class DateFormatterServiceMock: DateFormatterServiceProtocol {
    func formatDate(_ date: Date?) -> String {
        return "MockDate"
    }
}

final class LoadingIndicatorMock: LoadingIndicatorProtocol {
    func show() {}
    func dismiss() {}
}

final class ImagesListPresenterTests: XCTestCase {
    private var view: ImagesListViewMock!
    private var service: ImagesListServiceMock!
    private var tokenStorage: OAuth2TokenStorageMock!
    private var dateFormatterService: DateFormatterServiceMock!
    private var loadingIndicator: LoadingIndicatorMock!
    private var presenter: ImagesListPresenter!
    
    override func setUp() {
        super.setUp()
        view = ImagesListViewMock()
        service = ImagesListServiceMock()
        tokenStorage = OAuth2TokenStorageMock()
        dateFormatterService = DateFormatterServiceMock()
        loadingIndicator = LoadingIndicatorMock()
        
        presenter = ImagesListPresenter(
            view: view,
            service: service,
            tokenStorage: tokenStorage,
            dateFormatterService: dateFormatterService,
            loadingIndicator: loadingIndicator
        )
    }
    
    override func tearDown() {
        view = nil
        presenter = nil
        service = nil
        super.tearDown()
    }
    
    func testViewDidLoadLoadsPhotosIfTokenExists() {
        tokenStorage.token = "valid_token"
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(service.loadNextPageCalled)
    }
    
    func testPresenterInsertsNewRowsWhenPhotosWereAdded() {
        let oldPhoto = Photo(
            id: "1",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://old.thumb",
            regularImageURL: "http://old.regular",
            largeImageURL: "http://old.large",
            numberOfLikes: 5
        )
        
        let newPhoto = Photo(
            id: "2",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://new.thumb",
            regularImageURL: "http://new.regular",
            largeImageURL: "http://new.large",
            numberOfLikes: 3
        )
        presenter.photos = [oldPhoto]
        service.photos = [oldPhoto, newPhoto]
        
        presenter.didUpdatePhotos()
        
        XCTAssertEqual(view.insertRowsCalledAt, [IndexPath(row: 1, section: 0)])
    }
    
    func testPresenterReloadsTableWhenPhotosWereRemoved() {
        let oldPhoto1 = Photo(
            id: "1",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://old1.thumb",
            regularImageURL: "http://old1.regular",
            largeImageURL: "http://old1.large",
            numberOfLikes: 5
        )
        
        let oldPhoto2 = Photo(
            id: "2",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://old2.thumb",
            regularImageURL: "http://old2.regular",
            largeImageURL: "http://old2.large",
            numberOfLikes: 3
        )
        
        let newPhoto = Photo(
            id: "1",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://old1.thumb",
            regularImageURL: "http://old1.regular",
            largeImageURL: "http://old1.large",
            numberOfLikes: 5
        )
        
        presenter.photos = [oldPhoto1, oldPhoto2]
        service.photos = [newPhoto]
        
        presenter.didUpdatePhotos()
        
        XCTAssertTrue(view.reloadTableCalled)
    }
    
    func testPresenterCallsLoadNextPageWhenLastCellAndTokenExists() {
        let photo1 = Photo(
            id: "1",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://photo1.thumb",
            regularImageURL: "http://photo1.regular",
            largeImageURL: "http://photo1.large",
            numberOfLikes: 1
        )
        
        let photo2 = Photo(
            id: "2",
            size: CGSize(width: 10, height: 10),
            createdAt: nil,
            isLiked: false,
            description: nil,
            thumbImageURL: "http://photo2.thumb",
            regularImageURL: "http://photo2.regular",
            largeImageURL: "http://photo2.large",
            numberOfLikes: 2
        )
        
        view = ImagesListViewMock()
        service = ImagesListServiceMock()
        let tokenStorage = OAuth2TokenStorageMock()
        tokenStorage.token = "valid_token"
        
        presenter = ImagesListPresenter(
            view: view,
            service: service,
            tokenStorage: tokenStorage,
            dateFormatterService: DateFormatterServiceMock(),
            loadingIndicator: LoadingIndicatorMock()
        )
        
        presenter.photos = [photo1, photo2]
        
        presenter.willDisplayRow(at: IndexPath(row: 1, section: 0))
        
        XCTAssertTrue(service.loadNextPageCalled)
    }
}

