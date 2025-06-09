import Foundation

enum Constants {
    static let accessKey = "OTKUPw2krzeqT36i6gqarAVROSzIVc-FdCICwU6HfiU"
    static let secretKey = "HASb9OX85j9rOLXQPVBNQ-UOCIpuewf6qT8fEMMLU1E"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURLString = "https://api.unsplash.com/"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let unsplashAuthorizeURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURLString: String, unsplashAuthorizeURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURLString: Constants.defaultBaseURLString,
                                 unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString
        )
    }
}
