import Foundation
import UIKit

final class ImagesListPresenter {
    weak var view: ImagesListViewProtocol?
    
    var photos: [Photo] = []
    private let service: ImagesListServiceProtocol
    private let dateFormatterService: DateFormatterServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let loadingIndicator: LoadingIndicatorProtocol
    
    init(
        view: ImagesListViewProtocol,
        service: ImagesListServiceProtocol = ImagesListService.shared,
        tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage(),
        dateFormatterService: DateFormatterServiceProtocol = DateFormatterService(),
        loadingIndicator: LoadingIndicatorProtocol = UIBlockingProgressHUD.shared
    ) {
        self.view = view
        self.service = service
        self.tokenStorage = tokenStorage
        self.dateFormatterService = dateFormatterService
        self.loadingIndicator = loadingIndicator
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdatePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        if let token = tokenStorage.token {
            service.loadNextPage(token){ _ in }
        }
    }
    
    @objc func didUpdatePhotos() {
        let oldCount = photos.count
        let newPhotos = service.photos
        let newCount = service.photos.count
        
        if newCount < oldCount {
            photos = newPhotos
            view?.updatePhotos(newPhotos)
            view?.reloadTable()
            return
        }
        
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)}
            photos = newPhotos
            view?.updatePhotos(newPhotos)
            view?.insertRows(at: indexPaths)
        } else {
            view?.reloadTable()
        }
    }
    
    func makeCellViewModel(at indexPath: IndexPath) -> PhotoCellViewModel? {
        let photo = photos[indexPath.row]
        
        guard let url = URL(string: photo.regularImageURL) else {
            return nil
        }
        
        let image = UIImage(named: photo.regularImageURL)
        
        return PhotoCellViewModel(
            dateText: dateFormatterService.formatDate(photo.createdAt),
            isLiked: photo.isLiked,
            imageURL: url,
            image: nil
        )
    }
    
    func makeMockCellViewModel(at indexPath: IndexPath, image: UIImage?) -> PhotoCellViewModel? {
        guard photos.indices.contains(indexPath.row) else { return nil }
        let photo = photos[indexPath.row]
        return PhotoCellViewModel(
            dateText: dateFormatterService.formatDate(photo.createdAt),
            isLiked: photo.isLiked,
            imageURL: nil,
            image: image
        )
    }
    
    @MainActor func configure(_ cell: ImagesListCell, at indexPath: IndexPath) {
        guard let viewModel = makeCellViewModel(at: indexPath) else {
            cell.dateLabel.text = nil
            cell.setIsLiked(false)
            cell.cellImage.image = UIImage(named: "placeholder")
            return
        }
        
        cell.dateLabel.text = viewModel.dateText
        cell.setIsLiked(viewModel.isLiked)
        
        if let image = viewModel.image {
            cell.cellImage.image = image
        } else if let url = viewModel.imageURL {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: [.transition(.fade(0.3))]
            ) { [weak self] result in
                self?.loadingIndicator.dismiss()
            }
        } else {
            cell.cellImage.image = UIImage(named: "placeholder")
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let url = URL(string: photo.largeImageURL) else { return }
        view?.navigateToSingleImageScreen(with: url)
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        self.loadingIndicator.show()
        
        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.service.photos
                    self.view?.reloadRow(at: indexPath)
                    print("Like status changed successfully")
                    
                case .failure(let error):
                    print("Error during like tap: \(error.localizedDescription)")
                }
                
                self.loadingIndicator.dismiss()
            }
        }
    }
    
    func willDisplayRow(at indexPath: IndexPath){
        if indexPath.row == photos.count - 1,
           let token = tokenStorage.token {
            service.loadNextPage(token){ _ in }
        }
    }
}



