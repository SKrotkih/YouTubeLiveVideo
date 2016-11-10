
import Foundation
import UIKit
import Alamofire
import KeychainAccess

let kOAuth2AccessTokenService: String = "OAuth2AccessToken"
let kOAuth2RefreshTokenService: String = "OAuth2RefreshToken"
let kOAuth2ExpiresInService: String = "OAuth2ExpiresIn"
let kOAuth2CreationDateService: String = "OAuth2CreationDate"

class OAuth2Client : NSObject {
    
    var oauth2Settings:Oauth2Settings
    var sourceViewController:UIViewController?
    let keychain:  Keychain
    
    init(outh2Settings: Oauth2Settings) {
        self.oauth2Settings = outh2Settings
        self.keychain = Keychain(service: outh2Settings.baseURL)
    }
    
    private func postRequestHandler(jsonResponse:Any?, error:Error?, token:((_ accessToken:String?) -> Void)) -> Void {
        if let err = error {
            print(err)
            token(nil)
        } else {
            let accessToken:String = self.retrieveAccessTokenFromJSONResponse(jsonResponse: jsonResponse!)
            token(accessToken)
        }
    }
    
    func retrieveAuthToken(token:@escaping ((_ accessToken:String?) -> Void)) -> Void {
        
        // We found a token in the keychain, we need to check if it is not expired            
        if let optionalStoredAccessToken:String = self.retrieveAccessTokenFromKeychain() {
            if (self.isAccessTokenExpired()) {
                if let refreshToken = self.retrieveRefreshTokenFromKeychain() {
                    self.refreshToken(refreshToken: refreshToken, newToken: token)
                    return
                }
                print("WARNING: Access token is expired but no refresh token in keychain!")
            } else {
                token(optionalStoredAccessToken)
                return
            }
        }
        
        // First, let's retrieve the autorization_code by loging the user in.
        self.retrieveAuthorizationCode (authoCode: { (authorizationCode) -> Void in
            if let optionalAuthCode = authorizationCode {
                // We have the authorization_code, we now need to exchange it for the accessToken by doind a POST request
                let url:String = self.oauth2Settings.tokenURL
                
                let parameters: [String:String] = ["client_id" : self.oauth2Settings.clientID,
                    "grant_type" : "authorization_code",
                    "client_secret" : self.oauth2Settings.clientSecret,
                    "redirect_uri" : self.oauth2Settings.redirectURL,
                    "code" : optionalAuthCode]
                
                Alamofire.request(url, method: .post, parameters: parameters, headers: [
                    "Accept": "application/json",
                    ])
                    .responseJSON(completionHandler: { (response) -> Void in
                        switch response.result {
                        case .success(let json):
                            self.postRequestHandler(jsonResponse: json, error: nil, token: token)
                        case .failure(let error):
                            self.postRequestHandler(jsonResponse: nil, error: error, token: token)
                        }
                    })
            }
            else {
                token(nil)
            }
        })
    }
    
    // MARK: - Private helper methods
    
    var activeController: UIViewController {
        get {
            if self.sourceViewController == nil {
                self.sourceViewController = UIApplication.topViewController()
            }
            if self.sourceViewController != nil {
                return self.sourceViewController!
            }
            print("WARNING: You should have an active UIViewController! ")
            return UIViewController()
        }
    }

    // Retrieves the autorization code by presenting a webView that will let the user login
    private func retrieveAuthorizationCode(authoCode:@escaping ((_ authorizationCode:String?) -> Void)) -> Void{
        
        func success(code:String) -> Void {
            activeController.dismiss(animated: true, completion: nil)
            authoCode(code)
        }
        
        func failure(error:Error) -> Void {
            activeController.dismiss(animated: true, completion: nil)
            authoCode(nil)
        }
        
        let authenticationViewController:AuthenticationViewController = AuthenticationViewController(oauth2Settings: oauth2Settings, successCallback:success, failureCallback:failure)
        let navigationController:UINavigationController = UINavigationController(rootViewController: authenticationViewController)
        
        activeController.present(navigationController, animated:true, completion:nil)
    }
    
    
    // Checks if the token that is stored in the keychain is expired
    private func isAccessTokenExpired() -> Bool {

        var isTokenExpired: Bool = false
        
        let optionalExpiresIn:NSString? = keychain[kOAuth2ExpiresInService] as NSString?
        
        if let expiresInValue = optionalExpiresIn {
            isTokenExpired = true
            let expiresTimeInterval:TimeInterval = expiresInValue.doubleValue
            
            let optionalCreationDate:NSString? = keychain[kOAuth2CreationDateService] as NSString?
            
            if let creationDate = optionalCreationDate {
                let creationTimeInterval:TimeInterval = creationDate.doubleValue
                
                // need to refresh the token 
                if (NSDate().timeIntervalSince1970 < creationTimeInterval + expiresTimeInterval) {
                    isTokenExpired = false
                }   
            }   
        }
        
        return isTokenExpired
    }
    
    private func retrieveAccessTokenFromKeychain() -> String? {
        return keychain[kOAuth2AccessTokenService]
    }
    
    private func retrieveRefreshTokenFromKeychain() -> String? {
        return keychain[kOAuth2RefreshTokenService]
    }
    
    // Request a new access token with our refresh token
    func refreshToken(refreshToken:String, newToken:@escaping ((_ accessToken:String?) -> Void)) -> Void {
        
        print("Need to refresh the token with refreshToken : " + refreshToken)
        
        let url:String = self.oauth2Settings.tokenURL
            
        let parameters: [String:String] = ["client_id" : self.oauth2Settings.clientID,
            "grant_type" : "refresh_token",
            "client_secret" : self.oauth2Settings.clientSecret,
            "redirect_uri" : self.oauth2Settings.redirectURL,
            "refresh_token" : refreshToken]

        Alamofire.request(url, method: .post, parameters: parameters, headers: [
            "Accept": "application/json",
            ])
            .responseJSON { (response) -> Void in
                switch response.result {
                case .success(let json):
                    self.postRequestHandler(jsonResponse: json, error: nil, token: newToken)
                case .failure(let error):
                    self.postRequestHandler(jsonResponse: nil, error: error, token: newToken)
                }
        }
    }
    
    // Extract the accessToken from the JSON response that the authentication server returned
    private func retrieveAccessTokenFromJSONResponse(jsonResponse:Any?) -> String {

        var result:String = String()
        
        if let jsonResult: NSDictionary = jsonResponse as? NSDictionary {
            
            if let error : NSString = jsonResult["error"] as? NSString {
                if let error_description : NSString = jsonResult["error_description"] as? NSString {
                    print("error: \(error) - \(error_description)")
                    return result
                }
            }

            let optionalAccessToken : NSString? = jsonResult["access_token"] as? NSString
            let optionalRefreshToken : NSString? = jsonResult["refresh_token"] as? NSString
            let optionalExpiresIn : NSNumber? = jsonResult["expires_in"] as? NSNumber
            
            // Store the required info for future token refresh in the Keychain.
            if let accessToken = optionalAccessToken {
                result = accessToken as String
                keychain[kOAuth2AccessTokenService] = accessToken as String
            }
            if let refreshToken = optionalRefreshToken {
                keychain[kOAuth2RefreshTokenService] = refreshToken as String
            }
            if let expiresIn = optionalExpiresIn {
                keychain[kOAuth2ExpiresInService] = expiresIn.stringValue as String
            }
            
            let date:TimeInterval = NSDate().timeIntervalSince1970
            keychain[kOAuth2CreationDateService] = NSString(format: "%f", date) as String
        }
        
        return result
    }
    

}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController , top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
