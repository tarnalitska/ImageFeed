import UIKit
import ProgressHUD

protocol LoadingIndicatorProtocol: AnyObject {
    func show()
    func dismiss()
}

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func configure() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = UIColor.ypBlack
        ProgressHUD.colorAnimation = .lightGray
    }
    
    func show() {
        UIBlockingProgressHUD.window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    func dismiss() {
        UIBlockingProgressHUD.window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static let shared = UIBlockingProgressHUD()
}

extension UIBlockingProgressHUD: LoadingIndicatorProtocol {}
