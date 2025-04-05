import UIKit

final class ProfileViewController: UIViewController {
    private var fullNameLabel: UILabel?
    private var accountNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profileImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        
    }
    func createUI() {
        view.backgroundColor = UIColor(named: "YPBlack")
        
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "avatar")
        
        let fullNameLabel = UILabel()
        fullNameLabel.text = "Екатерина Новикова"
        fullNameLabel.textColor = UIColor(named: "YPWhite")
        fullNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        let accountNameLabel = UILabel()
        accountNameLabel.text = "@ekaterina_nov"
        accountNameLabel.textColor = UIColor(named: "YPGray")
        accountNameLabel.font = UIFont.systemFont(ofSize: 13)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(named: "YPWhite")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        self.profileImageView = profileImageView
        self.fullNameLabel = fullNameLabel
        self.accountNameLabel = accountNameLabel
        self.descriptionLabel = descriptionLabel
        
        let logoutButton = UIButton.systemButton(with: UIImage(named: "logout")!.withRenderingMode(.alwaysOriginal), target: self, action: #selector(buttonTapped))
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        accountNameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        view.addSubview(fullNameLabel)
        view.addSubview(accountNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
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
