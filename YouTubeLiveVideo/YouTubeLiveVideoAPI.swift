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

private func JSONResponseDataFormatter(_ data: Data) -> Data {
   do {
      let dataAsJSON = try JSONSerialization.jsonObject(with: data, options: [])
      let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
      return prettyData
   } catch {
      return data //fallback to original data if it cant be serialized
   }
}

let BaseURL = "https://www.googleapis.com/youtube/v3"

let requestClosure = { (endpoint: Moya.Endpoint<YouTubeLiveVideoAPI>, done: @escaping MoyaProvider<YouTubeLiveVideoAPI>.RequestResultClosure) in
   OAuth2.sharedInstance.requestToken() { token in
      if let token = token {
         var request = endpoint.urlRequest as URLRequest
         request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         var nserror: NSError! = NSError(domain: "YouTubeLiveVideoAPIHttp", code: 0, userInfo: nil)
         let error = Moya.Error.underlying(nserror)
         done(Result(request, failWith: error))
      } else {
         var nserror: NSError! = NSError(domain: "YouTubeLiveVideoAPIHttp", code: 4000, userInfo: ["NSLocalizedDescriptionKey": "Failed Google OAuth2 request token"])
         let error = Moya.Error.underlying(nserror)
         let request = endpoint.urlRequest as URLRequest
         done(Result(request, failWith: error))
      }
   }
}

let YouTubeLiveVideoProvider = MoyaProvider<YouTubeLiveVideoAPI>(requestClosure: requestClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

public enum YouTubeLiveVideoAPI {
   case listBroadcasts([String: AnyObject])
   case liveBroadcast([String: AnyObject])
   case transitionLiveBroadcast([String: AnyObject])
   case deleteLiveBroadcast([String: AnyObject])
   case bindLiveBroadcast([String: AnyObject])
   case liveStream([String: AnyObject])
   case deleteLiveStream([String: AnyObject])
}

extension YouTubeLiveVideoAPI: TargetType {
   public var baseURL: URL { return URL(string: BaseURL)! }
   
   public var method: Moya.Method {
      switch self {
      case .listBroadcasts:
         return .GET
      case .liveBroadcast:
         return .GET
      case .transitionLiveBroadcast:
         return .POST
      case .deleteLiveBroadcast:
         return .DELETE
      case .bindLiveBroadcast:
         return .POST
      case .liveStream:
         return .GET
      case .deleteLiveStream:
         return .DELETE
      }
   }
   
   public var path: String {
      switch self {
      case .listBroadcasts(_):
         return "/liveBroadcasts"
      case .liveBroadcast(_):
         return "/liveBroadcasts"
      case .transitionLiveBroadcast(_):
         return "/liveBroadcasts/transition"
      case .deleteLiveBroadcast(_):
         return "/liveBroadcasts"
      case .bindLiveBroadcast(_):
         return "/liveBroadcasts/bind"
      case .liveStream(_):
         return "/liveStreams"
      case .deleteLiveStream(_):
         return "/liveStreams"
         
      }
   }
   
   public var parameters: [String: Any]? {
      switch self {
      case .listBroadcasts(let parameters):
         return parameters
      case .liveBroadcast(let parameters):
         return parameters
      case .transitionLiveBroadcast(let parameters):
         return parameters
      case .deleteLiveBroadcast(let parameters):
         return parameters
      case .bindLiveBroadcast(let parameters):
         return parameters
      case .liveStream(let parameters):
         return parameters
      case .deleteLiveStream(let parameters):
         return parameters
         
      }
   }
   
   public var sampleData: Data {
      switch self {
      case .listBroadcasts(_):
         return Data()
      case .liveBroadcast(_):
         return Data()
      case .transitionLiveBroadcast(_):
         return Data()
      case .deleteLiveBroadcast(_):
         return Data()
      case .bindLiveBroadcast(_):
         return Data()
      case .liveStream(_):
         return Data()
      case .deleteLiveStream(_):
         return Data()
      }
   }
   
   public var multipartBody: [MultipartFormData]? {
      return []
   }
   
   public var task: Task {
      return .request
   }
   
}

public func url(_ route: TargetType) -> String {
   return route.baseURL.appendingPathComponent(route.path).absoluteString
}
