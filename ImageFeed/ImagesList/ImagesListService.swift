import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func loadNextPage(_ authToken: String, completion: ((Result<Void, Error>) -> Void)?)
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    
    static var didChangeNotification: Notification.Name { get }
}


final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private let storageService = OAuth2TokenStorage()
    
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage = 0
    private var isFetching = false
    
    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    func loadNextPage(_ authToken: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        assert(Thread.isMainThread)
        
        guard !isFetching else { return }
        isFetching = true
        
        let nextPage = lastLoadedPage + 1
        
        guard let request = makeNextPageRequest(authToken: authToken, page: nextPage) else {
            print("Error: failed to create token request")
            isFetching = false
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let photoResults):
                let newPhotos: [Photo] = photoResults.map { Photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage += 1
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos]
                )
                
            case .failure(let error):
                var responseString = ""
                
                if let appError = error as? AppError {
                    switch appError {
                    case .httpStatusError(let code, let data):
                        responseString = String(data: data, encoding: .utf8) ?? "[dataTask]: Unable to decode response data, code: \(code)"
                    default:
                        break
                    }
                }
                print("[dataTask]: Error while fetching images list: \(error.localizedDescription)\nResponse: \(responseString)")
            }
        }
        task.resume()
    }
    
    func changeLike( photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(AppError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<EmptyResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = photo.toggledLike()
                        self.photos[index] = newPhoto
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self
                        )
                    }
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func clearPhotos(){
        photos = []
        NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
    }
}

private extension ImagesListService {
    func makeNextPageRequest(authToken: String, page: Int) -> URLRequest? {
        
        guard let authToken = storageService.token else { return nil }
        
        var components = URLComponents(
            string: Constants.defaultBaseURLString +  "/photos"
        )
        
        components?.queryItems = [
            .init(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            print("Error: couldn't build url with page parameter")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(authToken)"
        ]
        
        return request
    }
    
    func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let authToken = storageService.token else { return nil }
        
        guard let url = URL(string: Constants.defaultBaseURLString +  "/photos/\(photoId)/like") else {
            print("Error: couldn't build url for isLiked parameter")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ?  HTTPMethod.delete.rawValue : HTTPMethod.post.rawValue
        request.allHTTPHeaderFields = [
            "Authorization" : "Bearer \(authToken)"
        ]
        return request
    }
}

extension ImagesListService: ImagesListServiceProtocol {}
