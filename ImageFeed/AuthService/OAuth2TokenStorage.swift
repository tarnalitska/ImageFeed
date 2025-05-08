import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2AccessToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let value = newValue {
                _ = KeychainWrapper.standard.set(value, forKey: tokenKey)
            } else {
                _ = KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func clearToken() {
        _ = KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
