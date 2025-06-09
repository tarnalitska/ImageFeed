import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileImageService: ProfileImageServiceProtocol
    private let profileService: ProfileServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(view: ProfileViewControllerProtocol, profileService: ProfileServiceProtocol, profileImageService: ProfileImageServiceProtocol) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        let profile = profileService.getProfile()
        
        guard let profile = profile else {
            print("Profile not found")
            return
        }
        
        let viewModel = ProfileViewModel(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio
        )
        view?.show(profile: viewModel)
        subscribetoAvatarUpdates()
        notifyCurrentAvatar()
    }
    
    func subscribetoAvatarUpdates() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: type(of: profileImageService).didChangeNotification,
                object: nil,
                queue: .main
            ) {
                [weak self] _ in
                self?.notifyCurrentAvatar()
            }
    }
    
    func notifyCurrentAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(with: url)
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    func confirmLogout() {
        ProfileLogoutService.shared.logout {
            self.view?.navigateToSplash()
        }
    }
}
