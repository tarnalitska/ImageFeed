import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    var profile: Profile?
    let tokenStorage = OAuth2TokenStorage()
    
    private var fullNameLabel: UILabel?
    private var accountNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profileImageView: UIImageView?
    private var logoutButton: UIButton?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        updateProfileDetails()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) {
                [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
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
        let button = UIButton.systemButton(with: UIImage(named: "logout")!.withRenderingMode(.alwaysOriginal), target: self, action: #selector(buttonTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func updateProfileDetails() {
        guard let profile = profile else {
            print("Profile not found")
            return
        }
        
        fullNameLabel?.text = profile.name
        accountNameLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else
        { return }
        
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
    
    @objc func buttonTapped() {
        fullNameLabel?.removeFromSuperview()
        fullNameLabel = nil
        
        accountNameLabel?.removeFromSuperview()
        accountNameLabel = nil
        
        descriptionLabel?.removeFromSuperview()
        descriptionLabel = nil
        
        profileImageView?.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView?.tintColor = .gray
        profileImageView?.widthAnchor.constraint(equalToConstant: 75).isActive = true
        profileImageView?.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
}
