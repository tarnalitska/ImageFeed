import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func show(profile: ProfileViewModel)
    func updateAvatar(with url: URL)
    func showLogoutAlert()
    func navigateToSplash()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    var profile: Profile?
    let tokenStorage = OAuth2TokenStorage()
    
    var fullNameLabel: UILabel?
    var accountNameLabel: UILabel?
    var descriptionLabel: UILabel?
    private var profileImageView: UIImageView?
    var logoutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        presenter?.viewDidLoad()
    }
    
    func configure(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    private func createUI() {
        view.backgroundColor = UIColor.ypBlack
        
        let profileImageView = createProfileImageView()
        
        let fullNameLabel = createLabel(
            text: "Екатерина Новикова",
            color: UIColor.ypWhite,
            font: UIFont.systemFont(ofSize: 23, weight: .bold)
        )
        
        let accountNameLabel = createLabel(
            text: "@ekaterina_nov",
            color: UIColor.ypGray,
            font: UIFont.systemFont(ofSize: 13)
        )
        
        let descriptionLabel = createLabel(
            text: "Hello, world!",
            color: UIColor.ypWhite,
            font: UIFont.systemFont(ofSize: 13)
        )
        
        let logoutButton = createLogoutButton()
        
        self.profileImageView = profileImageView
        self.fullNameLabel = fullNameLabel
        self.accountNameLabel = accountNameLabel
        self.descriptionLabel = descriptionLabel
        self.logoutButton = logoutButton
        
        
        [profileImageView, fullNameLabel, accountNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func createProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage.avatar
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }
    
    private func createLabel(text: String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createLogoutButton() -> UIButton {
        let button = UIButton.systemButton(with: UIImage(named: "logout")!.withRenderingMode(.alwaysOriginal), target: self, action: #selector(logoutButtonTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logout_button"
        return button
    }
    
    private func setupConstraints() {
        guard let profileImageView = profileImageView,
              let fullNameLabel = fullNameLabel,
              let accountNameLabel = accountNameLabel,
              let descriptionLabel = descriptionLabel,
              let logoutButton = logoutButton else {
            print("Error: Missing UI elements in setupConstraints")
            return
        }
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            accountNameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            accountNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        ])
    }
    
    func show(profile: ProfileViewModel){
        fullNameLabel?.text = profile.name
        accountNameLabel?.text = profile.login
        descriptionLabel?.text = profile.bio
    }
    
    func updateAvatar(with url: URL) {
        let size = CGSize(width: 70, height: 70)
        let processor = ResizingImageProcessor(referenceSize: size, mode: .aspectFill)
        |> RoundCornerImageProcessor(cornerRadius: size.width / 2)
        
        profileImageView?.kf.setImage(with: url, options: [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ])
    }
    
    @objc func logoutButtonTapped() {
        presenter?.didTapLogout()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.confirmLogout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }
    
    func navigateToSplash() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("No window found")
            return
        }
        let splashViewController = SplashViewController()
        let navigationController = UINavigationController(rootViewController: splashViewController)
        window.rootViewController = navigationController
    }
}
