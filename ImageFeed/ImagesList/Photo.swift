import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let isLiked: Bool
    let description: String?
    let thumbImageURL: String
    let regularImageURL: String
    let largeImageURL: String
    let numberOfLikes: Int
    
    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = Self.iso8601DateFormatter.date(from: result.createdAt)
        self.isLiked = result.likedByUser
        self.description = result.description
        self.thumbImageURL = result.urls.thumb
        self.regularImageURL = result.urls.regular
        self.largeImageURL = result.urls.full
        self.numberOfLikes = result.likes
    }
    
    init(
        id: String,
        size: CGSize,
        createdAt: Date?,
        isLiked: Bool,
        description: String?,
        thumbImageURL: String,
        regularImageURL: String,
        largeImageURL: String,
        numberOfLikes: Int
    ) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.isLiked = isLiked
        self.description = description
        self.thumbImageURL = thumbImageURL
        self.regularImageURL = regularImageURL
        self.largeImageURL = largeImageURL
        self.numberOfLikes = numberOfLikes
    }
}

extension Photo {
    func toggledLike() -> Photo {
        return Photo(
            id: self.id,
            size: self.size,
            createdAt: self.createdAt,
            isLiked: !self.isLiked,
            description: self.description,
            thumbImageURL: self.thumbImageURL,
            regularImageURL: self.regularImageURL,
            largeImageURL: self.largeImageURL,
            numberOfLikes: self.numberOfLikes
        )
    }
}
