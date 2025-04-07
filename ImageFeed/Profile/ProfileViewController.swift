import UIKit

final class ProfileViewController: UIViewController {
    private var fullNameLabel: UILabel?
    private var accountNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profileImageView: UIImageView?
    private var logoutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
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
