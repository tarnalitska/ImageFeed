import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    
    private var authImageView: UIImageView?
    private var loginButton: UIButton?
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        configureBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func createUI() {
        view.backgroundColor = UIColor.ypBlack
        
        let authImageView = createAuthImageView()
        let loginButton = createLoginButton()
        
        self.authImageView = authImageView
        self.loginButton = loginButton
        
        
        [authImageView, loginButton].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
        
    }
    
    private func createAuthImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage.authview
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func createLoginButton() -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitleColor(UIColor.ypBlack, for: .normal)
        button.backgroundColor = UIColor.ypWhite
        button.layer.cornerRadius = 16
        button.accessibilityIdentifier = "Authenticate"
        
        return button
    }
    
    private func setupConstraints() {
        guard let authImageView = authImageView,
              let loginButton = loginButton else {
            print("Error: Missing UI elements in setupConstraints")
            return
        }
        
        NSLayoutConstraint.activate([
            authImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.ypBlack
        navigationItem.backBarButtonItem?.accessibilityIdentifier = "back_button"
    }
    
    @objc private func buttonTapped() {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: self)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
