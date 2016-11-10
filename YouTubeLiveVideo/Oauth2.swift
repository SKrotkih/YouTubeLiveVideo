//
//  OAuth2.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/28/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import UIKit
import AlamofireOauth2

// Developer console
// https://console.developers.google.com/apis

// Create your own clientID at https://console.developers.google.com/project (secret can be left blank!)
// For more info see https://developers.google.com/identity/protocols/OAuth2WebServer#handlingtheresponse
// And https://developers.google.com/+/web/api/rest/oauth

class OAuth2: NSObject {

   var _googleOauth2Settings: Oauth2Settings?
   
   class var sharedInstance: OAuth2 {
      struct Singleton {
         static let instance = OAuth2()
      }
      return Singleton.instance
   }
   
   private var googleOauth2Settings: Oauth2Settings {
      if _googleOauth2Settings == nil {
         _googleOauth2Settings = Oauth2Settings(baseURL: Auth.BaseURL,
                                                authorizeURL: Auth.AuthorizeURL,
                                                tokenURL: Auth.TokenURL,
                                                redirectURL: Auth.RedirectURL,
                                                clientID: Private.GoogleClientID,
                                                clientSecret: Auth.ClientSecret,
                                                scope: Auth.Scope)
      }
      return _googleOauth2Settings!
   }

   func requestToken(_ completed: @escaping (String?) -> Void) {
      UsingOauth2(googleOauth2Settings, performWithToken: { token in
         completed(token)
      }, errorHandler: {
         print("Oauth2 failed")
         completed(nil)
      })
   }
   
   func clearToken() {
      Oauth2ClearTokensFromKeychain(googleOauth2Settings)
   }
   
}
