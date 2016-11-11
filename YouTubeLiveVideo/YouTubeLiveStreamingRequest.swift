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
import AeroGearOAuth2
import AeroGearHttp

class YouTubeLiveStreamingRequest: NSObject {

   // Set up broadcast on your Youtube account:
   // https://www.youtube.com/my_live_events
   // https://www.youtube.com/live_dashboard
   // Errors:
   // https://support.google.com/youtube/answer/3006768?hl=ru
   
   // Developer console
   // https://console.developers.google.com/apis
   // TODO: Change Client Id on yours:
   let kGoogleClientId = "<CLIENT ID>.apps.googleusercontent.com"
   
   // TODO: Change API key on yours:
   let kAPIkey = "<API KEY>"
   // This API key can be used in this project and with any API that supports it.
   // To use this key in your application, pass it with the key=API_KEY parameter.
}

// MARK: LiveBroatcasts
// https://developers.google.com/youtube/v3/live/docs/liveBroadcasts

extension YouTubeLiveStreamingRequest {

   // Returns a list of YouTube broadcasts that match the API request parameters.
   // broadcastStatus:
   // Acceptable values are:
   // active – Return current live broadcasts.
   // all – Return all broadcasts.
   // completed – Return broadcasts that have already ended.
   // upcoming – Return broadcasts that have not yet started.
   
   func listBroadcasts(status: String, completed: (LiveBroadcastListModel?) -> Void) {
      let parameters: [String: AnyObject] = [
      "part": "id,snippet,contentDetails,status",
      "broadcastStatus": status,
      "maxResults": 50,
      "key": self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.ListBroadcasts(parameters), completion: { result in
         switch result {
         case let .Success(response):
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
         case let .Failure(error):
            guard let error = error as? CustomStringConvertible else {
               break
            }
            let sferror: SFError = .NetworkError(message: error.description)
            print(sferror)
            completed(nil)
         }
      })
   }
   
   func getLiveBroadcast(broadcastId broadcastId: String, completed: (LiveBroadcastStreamModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "part":"id,snippet,contentDetails,status",
         "id":broadcastId,
         "key":self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.LiveBroadcast(parameters), completion: { result in
         switch result {
         case let .Success(response):
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
         case let .Failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("Системная ошибка", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   // https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/insert
   // Creates a broadcast.
   func createLiveBroadcast(title: String, startDateTime: NSDate, completed: (LiveBroadcastStreamModel?) -> Void) {
      OAuth2.sharedInstance.request() { token in
         if let token = token {
            let jsonBody = "{\"snippet\": {\"title\": \"\(title)\",\"scheduledStartTime\": \"\(self.dateToString(startDateTime))\"},\"status\": {\"privacyStatus\":\"public\"}}"
            let headers = merge(["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            let url = "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status&key=\(self.kAPIkey)"
            Alamofire.request(.POST, url, headers: headers,
               parameters: [:],
               encoding: .Custom({
                  (convertible, params) in
                  let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                  let dataBody = (jsonBody as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                  mutableRequest.HTTPBody = dataBody
                  return (mutableRequest, nil)
               })).response(completionHandler: {
                  (request, response, data, error) in
                  if let error = error {
                     Alert.sharedInstance.showOk("System error", message: error.localizedDescription)
                     completed(nil)
                  } else {
                     let json = JSON(data: data!)
                     let error = json["error"]
                     let message = error["message"].stringValue
                     if message.characters.count > 0 {
                        Alert.sharedInstance.showOk("Error while Youtube broadcast was creating", message: message)
                        completed(nil)
                     } else {
                        //print(json)
                        let liveBroadcast = LiveBroadcastStreamModel.decode(json)
                        completed(liveBroadcast)
                     }
                  }
               })
         } else {
            
         }
      }
   }
   
   // POST https://www.googleapis.com/youtube/v3/liveBroadcasts/transition
   // Changes the status of a YouTube live broadcast and initiates any processes associated with the new status. For example, when you transition a broadcast's status to testing, YouTube starts to transmit video to that broadcast's monitor stream. Before calling this method, you should confirm that the value of the status.streamStatus property for the stream bound to your broadcast is active.
   func transitionLiveBroadcast(boadcastId: String, broadcastStatus: String, completed: (LiveBroadcastStreamModel?) -> Void) {
      
      let parameters: [String: AnyObject] = [
         "id":boadcastId,
         "broadcastStatus":broadcastStatus,
         "part":"id,snippet,contentDetails,status",
         "key":self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.TransitionLiveBroadcast(parameters), completion: { result in
         switch result {
         case let .Success(response):
            let json = JSON(data: response.data)
            let error = json["error"]
            let message = error["message"].stringValue
            if message.characters.count > 0 {
               print("FAILED TRANSITION TO THE \(broadcastStatus) STATUS [\(message)]!")
               //Alert.sharedInstance.showOk("Error while Youtube broadcast transition", message: message)
               completed(nil)
            } else {
               print(json)
               let liveBroadcast = LiveBroadcastStreamModel.decode(json)
               completed(liveBroadcast)
            }
         case let .Failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("Системная ошибка", message: error.description)
            }
            completed(nil)
         }
      })
   }
   
   // Deletes a broadcast.
   // DELETE https://www.googleapis.com/youtube/v3/liveBroadcasts
   func deleteLiveBroadcast(broadcastId broadcastId: String, completed: (Bool) -> Void) {
      let parameters: [String: AnyObject] = [
         "id":broadcastId,
         "key":self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.DeleteLiveBroadcast(parameters), completion: { result in
         switch result {
         case let .Success(response):
            let json = JSON(data: response.data)
            let error = LiveBroadcastErrorModel.decode(json["error"])
            if error.code > 0 {
               Alert.sharedInstance.showOk("Failed to delete broadcast", message: error.message!)
               completed(false)
            } else {
               //print("Broadcast deleted: \(json)")
               completed(true)
            }
         case let .Failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("Системная ошибка", message: error.description)
            }
            completed(false)
         }
      })
   }
   
   // Binds a YouTube broadcast to a stream or removes an existing binding between a broadcast and a stream.
   // A broadcast can only be bound to one video stream, though a video stream may be bound to more than one broadcast.
   // POST https://www.googleapis.com/youtube/v3/liveBroadcasts/bind
   func bindLiveBroadcast(broadcastId broadcastId: String, liveStreamId streamId: String, completed: (LiveBroadcastStreamModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "id":broadcastId,
         "streamId":streamId,
         "part":"id,snippet,contentDetails,status",
         "key":self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.BindLiveBroadcast(parameters), completion: { result in
         switch result {
         case let .Success(response):
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
         case let .Failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("Системная ошибка", message: error.description)
            }
            completed(nil)
         }
      })
   }

   // Updates a broadcast. For example, you could modify the broadcast settings defined in the liveBroadcast resource's contentDetails object.
   // https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/update
   // PUT https://www.googleapis.com/youtube/v3/liveBroadcasts
   func updateLiveBroadcast(broadcastId id: String, title: String, format: String, completed: (Bool) -> Void) {
      OAuth2.sharedInstance.request() { token in
         if let token = token {
            let ingestionType = "rtmp" // dash rtmp
            let jsonBody = "{\"id\":\"\(id)\",\"snippet\": {\"title\":\"\(title)\"},\"cdn\":{\"format\":\"\(format)\",\"ingestionType\":\"\(ingestionType)\"}}}"
            let headers = merge(["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            Alamofire.request(.PUT, "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=\"id,snippet,contentDetails,status\"&key=\(self.kAPIkey)",
               headers: headers,
               parameters: nil,
               encoding: .Custom({
                  (convertible, params) in
                  let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                  let dataBody = (jsonBody as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                  mutableRequest.HTTPBody = dataBody
                  return (mutableRequest, nil)
               })).response(completionHandler: {
                  (request, response, data, error) in
                  if let error = error {
                     Alert.sharedInstance.showOk("System error", message: error.localizedDescription)
                     completed(false)
                  } else {
                     let json = JSON(data: data!)
                     let error = json["error"].stringValue
                     if error.characters.count > 0 {
                        let message = json["message"].stringValue
                        Alert.sharedInstance.showOk(error, message: message)
                        completed(false)
                     } else {
                        //print(json)
                        completed(true)
                     }
                  }
               })
         } else {
            
         }
      }
   }
}

// MARK: LiveStreams
// https://developers.google.com/youtube/v3/live/docs/liveStreams
// A liveStream resource contains information about the video stream that you are transmitting to YouTube.
// The stream provides the content that will be broadcast to YouTube users.
// Once created, a liveStream resource can be bound to one or more liveBroadcast resources.

extension YouTubeLiveStreamingRequest {
   
   // Returns a list of video streams that match the API request parameters.
   // https://developers.google.com/youtube/v3/live/docs/liveStreams/list
   func getLiveStream(liveStreamId: String, completed: (LiveStreamModel?) -> Void) {
      let parameters: [String: AnyObject] = [
         "part":"id,snippet,cdn,status",
         "id":liveStreamId,
         "key":self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.LiveStream(parameters), completion: { result in
         switch result {
         case let .Success(response):
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
         case let .Failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("Системная ошибка", message: error.description)
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
   
   func createLiveStream(title: String, description: String, streamName: String, completed: (LiveStreamModel?) -> Void) {
      OAuth2.sharedInstance.request() { token in
         if let token = token {
            let resolution = "720p"    // 1080p 1440p 240p 360p 480p 720p
            let frameRate = "60fps"    // 30fps
            let ingestionType = "rtmp" // dash rtmp
            
            let jsonBody = "{\"snippet\": {\"title\": \"\(title)\",\"description\": \"\(description)\"},\"cdn\": {\"resolution\":\"\(resolution)\",\"frameRate\":\"\(frameRate)\",\"ingestionType\":\"\(ingestionType)\",\"ingestionInfo\":{\"streamName\":\"\(streamName)\"}}}"
            let headers = merge(["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            let url = "https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status&key=\(self.kAPIkey)"
            Alamofire.request(.POST,
               url,
               headers: headers,
               parameters: [:],
               encoding: .Custom({
                  (convertible, params) in
                  let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                  let dataBody = (jsonBody as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                  mutableRequest.HTTPBody = dataBody
                  return (mutableRequest, nil)
               })).response(completionHandler: {
                  (request, response, data, error) in
                  if let error = error {
                     Alert.sharedInstance.showOk("System error", message: error.localizedDescription)
                     completed(nil)
                  } else {
                     let json = JSON(data: data!)
                     let error = json["error"]
                     let message = error["message"].stringValue
                     if message.characters.count > 0 {
                        Alert.sharedInstance.showOk("Error while Youtube live stream creating", message: message)
                        completed(nil)
                     } else {
                        //print(json)
                        let liveStream = LiveStreamModel.decode(json)
                        completed(liveStream)
                     }
                  }
               })
         } else {
            
         }
      }
   }
   
   // Deletes a video stream
   // Request:
   // DELETE https://www.googleapis.com/youtube/v3/liveStreams
   func deleteLiveStream(liveStreamId: String, completed: (Bool) -> Void) {
      let parameters: [String: AnyObject] = [
         "id":liveStreamId,
         "key":self.kAPIkey
      ]
      YouTubeLiveVideoProvider.request(YouTubeLiveVideoAPI.DeleteLiveStream(parameters), completion: { result in
         switch result {
         case let .Success(response):
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
         case let .Failure(error):
            if let error = error as? CustomStringConvertible {
               Alert.sharedInstance.showOk("Системная ошибка", message: error.description)
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
   
   func updateLiveStream(liveStreamId: String, title: String, format: String, ingestionType: String, completed: (Bool) -> Void) {
      OAuth2.sharedInstance.request() { token in
         if let token = token {
            let jsonBody = "{\"id\":\"\(liveStreamId)\",\"snippet\": {\"title\":\"\(title)\"},\"cdn\":{\"format\":\"\(format)\",\"ingestionType\":\"\(ingestionType)\"}}}"
            let headers = merge(["Content-Type": "application/json"], ["Authorization":"Bearer \(token)"])
            Alamofire.request(.PUT, "https://www.googleapis.com/youtube/v3/liveStreams", headers: headers,
               parameters: ["part": "id,snippet,cdn,status", "key": self.kAPIkey],
               encoding: .Custom({
                  (convertible, params) in
                  let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                  let dataBody = (jsonBody as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                  mutableRequest.HTTPBody = dataBody
                  return (mutableRequest, nil)
               })).response(completionHandler: {
                  (request, response, data, error) in
                  if let error = error {
                     Alert.sharedInstance.showOk("System error", message: error.localizedDescription)
                     completed(false)
                  } else {
                     let json = JSON(data: data!)
                     let error = json["error"].stringValue
                     if error.characters.count > 0 {
                        let message = json["message"].stringValue
                        Alert.sharedInstance.showOk(error, message: message)
                        completed(false)
                     } else {
                        //print(json)
                        completed(true)
                     }
                  }
               })
         } else {
            
         }
      }
   }
   
}

// MARK: Helper 

extension YouTubeLiveStreamingRequest {

   // Convert NSDate to the ISO 8601 format string
   // There is reverse converting in JsonUtility.dateWithJSONString()
   private func dateToString(date: NSDate) -> String {
      let dateFormatterDate = NSDateFormatter()
      dateFormatterDate.dateFormat = "yyyy-MM-dd HH:mm:ss"
      let dateStr = dateFormatterDate.stringFromDate(date)
      let startDateStr = String(dateStr.characters.map {
         $0 == " " ? "T" : $0
         })
      
      let timeZone: NSTimeZone = NSTimeZone.localTimeZone()
      let gmt = ("0" + String(timeZone.secondsFromGMTForDate(date) / 3600)) as NSString
      gmt.substringWithRange(NSRange(location: gmt.length - 2, length: 2))
      let startDate = startDateStr + "+" + (gmt as String) + ":00"
      return startDate
   }
   
}
