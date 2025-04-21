import WebKit

final class AuthResetHelper {
    
    static func resetLogin() {
        
        OAuth2TokenStorage().clearToken()
        
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            dataStore.removeData(ofTypes: dataTypes, for: records) {
                print("🌐 WebView cookies and website data cleared")
                
            }
        }
    }
}
