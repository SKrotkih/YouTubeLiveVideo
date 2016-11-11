//
//  YouTubeLiveVideoAPI.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/28/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import Moya
import Result

private func JSONResponseDataFormatter(data: NSData) -> NSData {
   do {
      let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
      let prettyData =  try NSJSONSerialization.dataWithJSONObject(dataAsJSON, options: .PrettyPrinted)
      return prettyData
   } catch {
      return data //fallback to original data if it cant be serialized
   }
}

let BaseURL = "https://www.googleapis.com/youtube/v3"

let requestClosure = { (endpoint: Moya.Endpoint<YouTubeLiveVideoAPI>, done: MoyaProvider<YouTubeLiveVideoAPI>.RequestResultClosure) in
   let request = endpoint.urlRequest.mutableCopy() as! NSMutableURLRequest
   OAuth2.sharedInstance.request() { token in
      if let token = token {
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         var nserror: NSError! = NSError(domain: "YouTubeLiveVideoAPIHttp", code: 0, userInfo: nil)
         let error = Moya.Error.Underlying(nserror)
         done(Result(request, failWith: error))
      } else {
         var nserror: NSError! = NSError(domain: "YouTubeLiveVideoAPIHttp", code: 4000, userInfo: ["NSLocalizedDescriptionKey": "Failed Google OAuth2 request token"])
         let error = Moya.Error.Underlying(nserror)
         done(Result(request, failWith: error))
      }
   }
}

let YouTubeLiveVideoProvider = MoyaProvider<YouTubeLiveVideoAPI>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)], requestClosure: requestClosure)

public enum YouTubeLiveVideoAPI {
   case ListBroadcasts([String: AnyObject])
   case LiveBroadcast([String: AnyObject])
   case TransitionLiveBroadcast([String: AnyObject])
   case DeleteLiveBroadcast([String: AnyObject])
   case BindLiveBroadcast([String: AnyObject])
   case LiveStream([String: AnyObject])
   case DeleteLiveStream([String: AnyObject])
}

extension YouTubeLiveVideoAPI: TargetType {
   public var baseURL: NSURL { return NSURL(string: BaseURL)! }
   
   public var method: Moya.Method {
      switch self {
      case .ListBroadcasts:
         return .GET
      case .LiveBroadcast:
         return .GET
      case .TransitionLiveBroadcast:
         return .POST
      case .DeleteLiveBroadcast:
         return .DELETE
      case .BindLiveBroadcast:
         return .POST
      case .LiveStream:
         return .GET
      case .DeleteLiveStream:
         return .DELETE
      }
   }
   
   public var path: String {
      switch self {
      case .ListBroadcasts(_):
         return "/liveBroadcasts"
      case .LiveBroadcast(_):
         return "/liveBroadcasts"
      case .TransitionLiveBroadcast(_):
         return "/liveBroadcasts/transition"
      case .DeleteLiveBroadcast(_):
         return "/liveBroadcasts"
      case BindLiveBroadcast(_):
         return "/liveBroadcasts/bind"
      case .LiveStream(_):
         return "/liveStreams"
      case DeleteLiveStream(_):
         return "/liveStreams"
         
      }
   }
   
   public var parameters: [String: AnyObject]? {
      switch self {
      case .ListBroadcasts(let parameters):
         return parameters
      case .LiveBroadcast(let parameters):
         return parameters
      case .TransitionLiveBroadcast(let parameters):
         return parameters
      case .DeleteLiveBroadcast(let parameters):
         return parameters
      case BindLiveBroadcast(let parameters):
         return parameters
      case .LiveStream(let parameters):
         return parameters
      case DeleteLiveStream(let parameters):
         return parameters
         
      }
   }
   
   public var sampleData: NSData {
      switch self {
      case .ListBroadcasts(_):
         return NSData()
      case .LiveBroadcast(_):
         return NSData()
      case .TransitionLiveBroadcast(_):
         return NSData()
      case .DeleteLiveBroadcast(_):
         return NSData()
      case BindLiveBroadcast(_):
         return NSData()
      case .LiveStream(_):
         return NSData()
      case .DeleteLiveStream(_):
         return NSData()
      }
   }
   
   public var multipartBody: [MultipartFormData]? {
      return []
   }
}

public func url(route: TargetType) -> String {
   return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
}
