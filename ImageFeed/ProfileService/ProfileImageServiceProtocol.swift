import Foundation

protocol ProfileImageServiceProtocol: AnyObject {
    static var didChangeNotification: Notification.Name { get }
    var avatarURL: String? { get }
}
