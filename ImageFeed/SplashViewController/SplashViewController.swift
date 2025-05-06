import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    
    
    override func viewDidAppear(_ animated: Bool) {
        AuthResetHelper.shared.resetLogin()

        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        }  else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController(with profile: Profile) {
        DispatchQueue.main.async {
            guard self != nil else { return }
        
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("No available window")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController,
                          let profileViewController = tabBarController.viewControllers?.first(where: { $0 is ProfileViewController }) as? ProfileViewController else {
                        assertionFailure("TabBarController or ProfileViewController not configured correctly")
                        return
                    }

            profileViewController.profile = profile
            
            window.rootViewController = tabBarController
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            navigationController.modalPresentationStyle = .fullScreen
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        var username: String?
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    username = profile.username
                    self.fetchProfileImage(username: username)
                    self.switchToTabBarController(with: profile)
                    
                case .failure(let error):
                    assertionFailure("❌ Failed to fetch profile with \(error)")
                    return
                }
            }
        }
    }
    
    func fetchProfileImage(username: String?){
        guard let username = username else {
            return
        }
        
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            switch result {
            case .success:
                print("success!")
            case .failure(let error):
                assertionFailure("❌ Failed to fetch profile image with \(error)")
                return
            }
        }
    }
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            UIBlockingProgressHUD.show()
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                guard let token = self.storage.token else { return }
                self.fetchProfile(token)
            case .failure:
                showAuthErrorAlert()
                break
            }
        }
    }
}

extension SplashViewController {
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: "Login failed",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
