//
//  YTLiveStreaming.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class YTLiveStreaming: NSObject {
   
}

extension YTLiveStreaming {
   
   func getActiveBroadcasts(_ completed: @escaping ([LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts("active", completed: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completed: completed)
         } else {
            completed(nil)
         }
      })
   }
   
   func getCompletedBroadcasts(_ completed: @escaping ([LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts("completed", completed: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completed: completed)
         } else {
            completed(nil)
         }
      })
   }
   
   func getUpcomingBroadcasts(_ completed: @escaping ([LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts("upcoming", completed: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completed: completed)
         } else {
            completed(nil)
         }
      })
   }
   
   fileprivate func fillList(_ broadcasts: LiveBroadcastListModel, completed: ([LiveBroadcastStreamModel]?) -> Void) {
      let items = broadcasts.items
      let sortedItems = items.sorted(by: { JsonUtility.date(withJSONString: $0.snipped.publishedAt).compare(JsonUtility.date(withJSONString: $1.snipped.publishedAt)) == ComparisonResult.orderedDescending })
      completed(sortedItems)
   }
   
   func createBroadcast(_ title: String, description: String, startTime: Date, completed: @escaping (Bool) -> Void) {
      
      // Create Live broadcast
      let liveStreamDescription = "This stream was created by the YouTubeLiveVideo iOS application"
      let liveStreamName = "Test"
      
      YTLiveRequest.createLiveBroadcast(title, startDateTime: startTime, completed: { liveBroadcastModel in
         if let liveBroadcast = liveBroadcastModel {
            // Create Live stream
            YTLiveRequest.createLiveStream(title, description: liveStreamDescription, streamName: liveStreamName) { liveStream in
               if let liveStream = liveStream {
                  // Bind live stream
                  YTLiveRequest.bindLiveBroadcast(broadcastId: liveBroadcast.id, liveStreamId: liveStream.id, completed: { liveBroadcast in
                     if let _ = liveBroadcast {
                        completed(true)
                     } else {
                        completed(false)
                     }
                  })
               } else {
                  print("Something went wrong")
                  completed(false)
               }
            }
         } else {
            print("Something went wrong")
            completed(false)
         }
      })
      
   }
   
   func startBroadcast(_ broadcast: LiveBroadcastStreamModel, completed: @escaping (LiveStreamModel?, LiveBroadcastStreamModel?) -> Void) {
      let broadcastId = broadcast.id
      let liveStreamId = broadcast.contentDetails.boundStreamId
      if broadcastId.characters.count > 0 &&  liveStreamId.characters.count > 0 {
         YTLiveRequest.getLiveBroadcast(broadcastId: broadcastId) { liveBroadcast in
            if let liveBroadcast = liveBroadcast {
               YTLiveRequest.getLiveStream(liveStreamId, completed: { liveStream in
                  if let liveStream = liveStream {
                     completed(liveStream, liveBroadcast)
                  }
               })
            } else {
               print("Something went wrong. Please xheck broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
               completed(nil, nil)
            }
         }
      } else {
         print("Something went wrong. Please xheck broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
         completed(nil, nil)
      }
   }
   
   func completeBroadcast(_ broadcast: LiveBroadcastStreamModel, completed: @escaping (Bool) -> Void) {
      // complete – The broadcast is over. YouTube stops transmitting video.
      YTLiveRequest.transitionLiveBroadcast(broadcast.id, broadcastStatus: "complete", completed: { liveBroadcast in
         if let _ = liveBroadcast {
            completed(true)
         } else {
            completed(false)
         }
      })
      
   }

   func deleteBroadcast(id: String, completed: @escaping (Bool) -> Void) {
      YTLiveRequest.deleteLiveBroadcast(broadcastId: id, completed: completed)
   }

   func transitionBroadcast(_ broadcast: LiveBroadcastStreamModel, toStatus: String, completed: @escaping (Bool) -> Void) {
         // complete – The broadcast is over. YouTube stops transmitting video.
         // live – The broadcast is visible to its audience. YouTube transmits video to the broadcast's monitor stream and its broadcast stream.
         // testing – Start testing the broadcast. YouTube transmits video to the broadcast's monitor stream.
         YTLiveRequest.transitionLiveBroadcast(broadcast.id, broadcastStatus: toStatus, completed: { liveBroadcast in
            if let _ = liveBroadcast {
               completed(true)
               print("Our broadcast in the \(toStatus) status!")
            } else {
               completed(false)
            }
         })
   }
   
   func getStatusBroadcast(_ broadcast: LiveBroadcastStreamModel, stream: LiveStreamModel, completed: @escaping (String?, String?, String?) -> Void) {
      YTLiveRequest.getLiveBroadcast(broadcastId: broadcast.id, completed: { broadcast in
         if let broadcast = broadcast {
            let broadcastStatus = broadcast.status.lifeCycleStatus
            
            //            Valid values for this property are:
            //            abandoned – This broadcast was never started.
            //            complete – The broadcast is finished.
            //            created – The broadcast has incomplete settings, so it is not ready to transition to a live or testing status, but it has been created and is otherwise valid.
            //            live – The broadcast is active.
            //            liveStarting – The broadcast is in the process of transitioning to live status.
            //            ready – The broadcast settings are complete and the broadcast can transition to a live or testing status.
            //            reclaimed – This broadcast has been reclaimed.
            //            revoked – This broadcast was removed by an admin action.
            //            testStarting – The broadcast is in the process of transitioning to testing status.
            //            testing – The broadcast is only visible to the partner.
            
            YTLiveRequest.getLiveStream(stream.id, completed: { liveStream in
               if let liveStream = liveStream {
                  //            Valid values for this property are:
                  //            active – The stream is in active state which means the user is receiving data via the stream.
                  //            created – The stream has been created but does not have valid CDN settings.
                  //            error – An error condition exists on the stream.
                  //            inactive – The stream is in inactive state which means the user is not receiving data via the stream.
                  //            ready – The stream has valid CDN settings.
                  let streamStatus = liveStream.status.streamStatus
                  
                  //            Valid values for this property are:
                  //            good – There are no configuration issues for which the severity is warning or worse.
                  //            ok – There are no configuration issues for which the severity is error.
                  //            bad – The stream has some issues for which the severity is error.
                  //            noData – YouTube's live streaming backend servers do not have any information about the stream's health status.
                  let healthStatus = liveStream.status.healthStatus.status
                  completed(broadcastStatus, streamStatus, healthStatus)
               } else {
                  completed(nil, nil, nil)
               }
            })
         } else {
            completed(nil, nil, nil)
         }
      })
   }
}

// MARK: Utils

extension YTLiveStreaming {
   
   fileprivate func deleteAllBroadcasts(_ completed: @escaping (Bool) -> Void) {
      YTLiveRequest.listBroadcasts("all", completed: { broadcastList in
         if let broadcastList = broadcastList {
            let items = broadcastList.items
            self.deleteBroadcast(items, index: 0, completed: completed)
         } else {
            completed(false)
         }
      })
   }
   
   fileprivate func deleteBroadcast(_ items: [LiveBroadcastStreamModel], index: Int, completed: @escaping (Bool) -> Void) {
      if index < items.count {
         let item = items[index]
         let broadcastId = item.id
         self.deleteBroadcast(id: broadcastId, completed: { success in
            if success {
               print("Broadcast \"\(broadcastId)\" deleted!")
            }
            self.deleteBroadcast(items, index: index + 1, completed: completed)
         })
      } else {
         completed(true)
      }
   }
}

// MARK Tests

extension YTLiveStreaming {
   
   func testUpdateLiveStream() {
      let liveStreamId = "0"
      let title = "Live Stream"
      let format = "1080p"    // 1080p 1440p 240p 360p 480p 720p
      let ingestionType = "rtmp" // dash rtmp
      YTLiveRequest.updateLiveStream(liveStreamId, title: title, format: format, ingestionType: ingestionType, completed: { success in
         
         if success {
            print("All right")
         } else {
            print("Something went wrong")
         }
         
      })
   }
   
}
