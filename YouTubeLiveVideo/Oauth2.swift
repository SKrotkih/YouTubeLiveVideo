//
//  Oauth2.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/28/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import UIKit
import AeroGearOAuth2
import AeroGearHttp

class Oauth2: NSObject {

   // Developer console
   // https://console.developers.google.com/apis
   // TODO: Change Client Id on yours:
   let kGoogleClientId = "495403403209-heee4af4qefp6ujvi216ar5rockjnr6l.apps.googleusercontent.com"
   
   // access a shared instance
   class var sharedInstance: Oauth2 {
      struct Singleton {
         static let instance = Oauth2()
      }
      return Singleton.instance
   }
   
}

// MARK: Google Oauth2

extension Oauth2 {
   
   func request(completed: (String?) -> Void) {
      let scopes = ["https://www.googleapis.com/auth/youtube"]
      let googleConfig = GoogleConfig(clientId: kGoogleClientId, scopes: scopes)
      let oauth2Module = OAuth2Module(config: googleConfig)
      let http = Http()
      http.authzModule = oauth2Module
      oauth2Module.requestAccess { (response:AnyObject?, error:NSError?) -> Void in
         if let error = error {
            print("Error: \(error)")
            completed(nil)
         } else {
            completed(response as? String)
         }
      }
   }
}
