//
//  YouTubeLiveStreamingRequest.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class YouTubeLiveStreamingRequest: NSObject {
   
   // Set up broadcast on your Youtube account:
   // https://www.youtube.com/my_live_events
   // https://www.youtube.com/live_dashboard
   // Errors:
   // https://support.google.com/youtube/answer/3006768?hl=ru
   
   // Developer console
   // https://console.developers.google.com/apis/credentials/key/0?project=fightnights-143711
}

// MARK: LiveBroatcasts requests
// https://developers.google.com/youtube/v3/live/docs/liveBroadcasts

extension YouTubeLiveStreamingRequest {
   
   // Returns a list of YouTube broadcasts that match the API request parameters.
   // broadcastStatus:
   // Acceptable values are:
   // active – Return current live broadcasts.
   // all – Return all broadcasts.
   // completed – Return broadcasts that have already ended.
   // upcoming – Return broadcasts that have not yet started.
   
   func listBroadcasts(_ status: String, completed: @escaping (LiveBroadcastListModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "part": "id,snippet,contentDetails,status" as AnyObject,
         "broadcastStatus": status as AnyObject,
         "maxResults": 50 as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.listBroadcasts(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = json["error"]
            let message = error["message"].stringValue
            if message.characters.count > 0 {
               Alert.sharedInstance.showOk("Failed to get broadcast info", message: message)
               completed(nil)
            } else {
               //print(json)
               let broadcastList = LiveBroadcastListModel.decode(json)
               let totalResults = broadcastList.pageInfo.totalResults
               let resultsPerPage = broadcastList.pageInfo.resultsPerPage
               
               print("Broadcasts total count = \(totalResults)")
               
               if totalResults > resultsPerPage {
                  print("Need to read next page!")  // TODO: In this case you should send request with pageToken=nextPageToken or pageToken=prevPageToken parameter
               }
               
               completed(broadcastList)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   func getLiveBroadcast(broadcastId: String, completed: @escaping (LiveBroadcastStreamModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "part":"id,snippet,contentDetails,status" as AnyObject,
         "id":broadcastId as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.liveBroadcast(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = json["error"]
            let message = error["message"].stringValue
            if message.characters.count > 0 {
               Alert.sharedInstance.showOk("Error while request broadcast list", message: message)
               completed(nil)
            } else {
               //print(json)
               let broadcastList = LiveBroadcastListModel.decode(json)
               let items = broadcastList.items
               var broadcast: LiveBroadcastStreamModel?
               for item in items {
                  if item.id == broadcastId {
                     broadcast = item
                     break
                  }
               }
               completed(broadcast)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   // https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/insert
   // Creates a broadcast.
   func createLiveBroadcast(_ title: String, startDateTime: Date, completed: @escaping (LiveBroadcastStreamModel?) -> Void) {
      OAuth2.sharedInstance.requestToken() { token in
         if let token = token {
            let headers = merge(one: ["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            let jsonBody = "{\"snippet\": {\"title\": \"\(title)\",\"scheduledStartTime\": \"\(startDateTime.toJSONformat())\"},\"status\": {\"privacyStatus\":\"public\"}}"
            let encoder = JSONBodyStringEncoding(jsonBody: jsonBody)
            let url = "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status&key=\(Private.APIkey)"
            Alamofire.request(url,
                              method: .post,
                              parameters: [:],
                              encoding: encoder,
                              headers: headers)
               .validate()
               .responseData { response in
                  switch response.result {
                  case .success:
                     guard let data = response.data else {
                        completed(nil)
                        return
                     }
                     let json = JSON(data: data)
                     let error = json["error"].stringValue
                     if error.characters.count > 0 {
                        let message = json["message"].stringValue
                        Alert.sharedInstance.showOk("Error while Youtube broadcast was creating", message: message)
                        completed(nil)
                     } else {
                        //print(json)
                        let liveBroadcast = LiveBroadcastStreamModel.decode(json)
                        completed(liveBroadcast)
                     }
                  case .failure(let error):
                     Alert.sharedInstance.showOk("System Error", message: error.localizedDescription)
                     completed(nil)
                  }
            }
         } else {
            completed(nil)
         }
      }
   }
   
   // POST https://www.googleapis.com/youtube/v3/liveBroadcasts/transition
   // Changes the status of a YouTube live broadcast and initiates any processes associated with the new status. For example, when you transition a broadcast's status to testing, YouTube starts to transmit video to that broadcast's monitor stream. Before calling this method, you should confirm that the value of the status.streamStatus property for the stream bound to your broadcast is active.
   func transitionLiveBroadcast(_ boadcastId: String, broadcastStatus: String, completed: @escaping (LiveBroadcastStreamModel?) -> Void) {
      
      let parameters: [String: AnyObject] = [
         "id":boadcastId as AnyObject,
         "broadcastStatus":broadcastStatus as AnyObject,
         "part":"id,snippet,contentDetails,status" as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.transitionLiveBroadcast(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = json["error"]
            let message = error["message"].stringValue
            if message.characters.count > 0 {
               print("FAILED TRANSITION TO THE \(broadcastStatus) STATUS [\(message)]!")
               //Alert.sharedInstance.showOk("Error while Youtube broadcast transition", message: message)
               completed(nil)
            } else {
               //print(json)
               let liveBroadcast = LiveBroadcastStreamModel.decode(json)
               completed(liveBroadcast)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   // Deletes a broadcast.
   // DELETE https://www.googleapis.com/youtube/v3/liveBroadcasts
   func deleteLiveBroadcast(broadcastId: String, completed: @escaping (Bool) -> Void) {
      let parameters: [String: AnyObject] = [
         "id":broadcastId as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.deleteLiveBroadcast(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = LiveBroadcastErrorModel.decode(json["error"])
            if let code = error.code, code > 0 {
               Alert.sharedInstance.showOk("Failed to delete broadcast", message: error.message!)
               completed(false)
            } else {
               //print("Broadcast deleted: \(json)")
               completed(true)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(false)
         }
      })
   }
   
   // Binds a YouTube broadcast to a stream or removes an existing binding between a broadcast and a stream.
   // A broadcast can only be bound to one video stream, though a video stream may be bound to more than one broadcast.
   // POST https://www.googleapis.com/youtube/v3/liveBroadcasts/bind
   func bindLiveBroadcast(broadcastId: String, liveStreamId streamId: String, completed: @escaping (LiveBroadcastStreamModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "id":broadcastId as AnyObject,
         "streamId":streamId as AnyObject,
         "part":"id,snippet,contentDetails,status" as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.bindLiveBroadcast(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = json["error"]
            let message = error["message"].stringValue
            if message.characters.count > 0 {
               Alert.sharedInstance.showOk("Error while Youtube broadcast binding with live stream", message: message)
               completed(nil)
            } else {
               //print(json)
               let liveBroadcast = LiveBroadcastStreamModel.decode(json)
               completed(liveBroadcast)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   // Updates a broadcast. For example, you could modify the broadcast settings defined in the liveBroadcast resource's contentDetails object.
   // https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/update
   // PUT https://www.googleapis.com/youtube/v3/liveBroadcasts
   func updateLiveBroadcast(broadcastId id: String, title: String, format: String, completed: @escaping (Bool) -> Void) {
      OAuth2.sharedInstance.requestToken() { token in
         if let token = token {
            let ingestionType = "rtmp" // dash rtmp
            let headers = merge(one: ["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            let jsonBody = "{\"id\":\"\(id)\",\"snippet\": {\"title\":\"\(title)\"},\"cdn\":{\"format\":\"\(format)\",\"ingestionType\":\"\(ingestionType)\"}}}"
            let encoder = JSONBodyStringEncoding(jsonBody: jsonBody)
            Alamofire.request("https://www.googleapis.com/youtube/v3/liveBroadcasts?part=\"id,snippet,contentDetails,status\"&key=\(Private.APIkey)", method: .put,
                              parameters: nil,
                              encoding: encoder,
                              headers: headers)
               .validate()
               .responseData { response in
                  switch response.result {
                  case .success:
                     guard let data = response.data else {
                        completed(false)
                        return
                     }
                     let json = JSON(data: data)
                     let error = json["error"].stringValue
                     if error.characters.count > 0 {
                        let message = json["message"].stringValue
                        Alert.sharedInstance.showOk("Error while Youtube broadcast was creating", message: message)
                        completed(false)
                     } else {
                        completed(true)
                     }
                  case .failure(let error):
                     Alert.sharedInstance.showOk("System Error", message: error.localizedDescription)
                     completed(false)
                  }
            }
         } else {
            completed(false)
         }
      }
   }
}

// MARK: LiveStreams requests
// https://developers.google.com/youtube/v3/live/docs/liveStreams
// A liveStream resource contains information about the video stream that you are transmitting to YouTube.
// The stream provides the content that will be broadcast to YouTube users.
// Once created, a liveStream resource can be bound to one or more liveBroadcast resources.

extension YouTubeLiveStreamingRequest {
   
   // Returns a list of video streams that match the API request parameters.
   // https://developers.google.com/youtube/v3/live/docs/liveStreams/list
   func getLiveStream(_ liveStreamId: String, completed: @escaping (LiveStreamModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "part":"id,snippet,cdn,status" as AnyObject,
         "id":liveStreamId as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.liveStream(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = json["error"]
            let message = error["message"].stringValue
            if message.characters.count > 0 {
               Alert.sharedInstance.showOk("Error while Youtube broadcast creating", message: message)
               completed(nil)
            } else {
               //print(json)
               let broadcastList = LiveStreamListModel.decode(json)
               let items = broadcastList.items
               var liveStream: LiveStreamModel?
               for item in items {
                  if item.id == liveStreamId {
                     liveStream = item
                     break
                  }
               }
               completed(liveStream)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   // https://developers.google.com/youtube/v3/live/docs/liveStreams/insert
   // Creates a video stream. The stream enables you to send your video to YouTube,
   // which can then broadcast the video to your audience.
   
   
   //   Request
   //
   //   POST https://www.googleapis.com/youtube/v3/liveStreams?part=id%2Csnippet%2Ccdn%2Cstatus&key={YOUR_API_KEY}
   //   {
   //   "snippet": {
   //   "title": "My First Live Video",
   //   "description": "Description live video"
   //   },
   //   "cdn": {
   //   "format": "1080p",
   //   "ingestionType": "rtmp",
   //   "ingestionInfo": {
   //   "streamName": "stream name 1"
   //   }
   //   }
   //   }
   
   func createLiveStream(_ title: String, description: String, streamName: String, completed: @escaping (LiveStreamModel?) -> Void) {
      OAuth2.sharedInstance.requestToken() { token in
         if let token = token {
            let resolution = LiveAPI.Resolution
            let frameRate = LiveAPI.FrameRate
            let ingestionType = LiveAPI.IngestionType
            let headers = merge(one: ["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            let jsonBody = "{\"snippet\": {\"title\": \"\(title)\",\"description\": \"\(description)\"},\"cdn\": {\"resolution\":\"\(resolution)\",\"frameRate\":\"\(frameRate)\",\"ingestionType\":\"\(ingestionType)\",\"ingestionInfo\":{\"streamName\":\"\(streamName)\"}}}"
            let encoder = JSONBodyStringEncoding(jsonBody: jsonBody)
            let url = "https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status&key=\(Private.APIkey)"
            Alamofire.request(url,
                              method: .post,
                              parameters: [:],
                              encoding: encoder,
                              headers: headers)
               .validate()
               .responseData { response in
                  switch response.result {
                  case .success:
                     guard let data = response.data else {
                        completed(nil)
                        return
                     }
                     let json = JSON(data: data)
                     let error = json["error"].stringValue
                     if error.characters.count > 0 {
                        let message = json["message"].stringValue
                        Alert.sharedInstance.showOk("Error while Youtube broadcast was creating", message: message)
                        completed(nil)
                     } else {
                        let liveStream = LiveStreamModel.decode(json)
                        completed(liveStream)
                     }
                  case .failure(let error):
                     Alert.sharedInstance.showOk("System Error", message: error.localizedDescription)
                     completed(nil)
                  }
            }
         } else {
            
         }
      }
   }
   
   // Deletes a video stream
   // Request:
   // DELETE https://www.googleapis.com/youtube/v3/liveStreams
   func deleteLiveStream(_ liveStreamId: String, completed: @escaping (Bool) -> Void) {
      let parameters: [String: AnyObject] = [
         "id":liveStreamId as AnyObject,
         "key": Private.APIkey as AnyObject
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.deleteLiveStream(parameters), completion: { result in
         switch result {
         case let .success(response):
            let json = JSON(data: response.data)
            let error = json["error"].stringValue
            if error.characters.count > 0 {
               let message = json["message"].stringValue
               Alert.sharedInstance.showOk(error, message: message)
               completed(false)
            } else {
               print("video stream deleted: \(json)")
               completed(true)
            }
         case let .failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("System Error", message: error.description)
            }
            completed(false)
         }
      })
   }
   
   // Updates a video stream. If the properties that you want to change cannot be updated, then you need to create a new stream with the proper settings.
   // Request:
   // PUT https://www.googleapis.com/youtube/v3/liveStreams
   // format = 1080p 1440p 240p 360p 480p 720p
   // ingestionType = dash rtmp
   
   func updateLiveStream(_ liveStreamId: String, title: String, format: String, ingestionType: String, completed: @escaping (Bool) -> Void) {
      OAuth2.sharedInstance.requestToken() { token in
         if let token = token {
            let headers = merge(one: ["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            let jsonBody = "{\"id\":\"\(liveStreamId)\",\"snippet\": {\"title\":\"\(title)\"},\"cdn\":{\"format\":\"\(format)\",\"ingestionType\":\"\(ingestionType)\"}}}"
            let encoder = JSONBodyStringEncoding(jsonBody: jsonBody)
            Alamofire.request("https://www.googleapis.com/youtube/v3/liveStreams",
                              method: .put,
                              parameters: ["part": "id,snippet,cdn,status", "key": Private.APIkey],
                              encoding: encoder,
                              headers: headers)
               .validate()
               .responseData { response in
                  switch response.result {
                  case .success:
                     guard let data = response.data else {
                        completed(false)
                        return
                     }
                     let json = JSON(data: data)
                     let error = json["error"].stringValue
                     if error.characters.count > 0 {
                        let message = json["message"].stringValue
                        Alert.sharedInstance.showOk("Error while Youtube broadcast was creating", message: message)
                        completed(false)
                     } else {
                        completed(true)
                     }
                  case .failure(let error):
                     Alert.sharedInstance.showOk("System Error", message: error.localizedDescription)
                     completed(false)
                  }
            }
         } else {
            completed(false)
         }
      }
   }
}

struct JSONBodyStringEncoding: ParameterEncoding {
   private let jsonBody: String
   
   init(jsonBody: String) {
      self.jsonBody = jsonBody
   }
   
   func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
      var urlRequest = urlRequest.urlRequest
      let dataBody = (jsonBody as NSString).data(using: String.Encoding.utf8.rawValue)
      if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
         urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      urlRequest?.httpBody = dataBody
      return urlRequest!
   }
}
