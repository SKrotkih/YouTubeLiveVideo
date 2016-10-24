//
//  YouTubeLiveStreamingWorker.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class YouTubeLiveStreamingWorker: NSObject {
   var youTubeRequest: YouTubeLiveStreamingRequest!
   var youTubePresenter: YouTubeLiveStreamingPresenter!
}

extension YouTubeLiveStreamingWorker {
   
   func getActiveBroadcasts(completed: ([LiveBroadcastStreamModel]?) -> Void) {
      youTubeRequest.listBroadcasts("active", completed: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completed: completed)
         } else {
            completed(nil)
         }
      })
   }

   func getCompletedBroadcasts(completed: ([LiveBroadcastStreamModel]?) -> Void) {
      youTubeRequest.listBroadcasts("completed", completed: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completed: completed)
         } else {
            completed(nil)
         }
      })
   }
   
   func getUpcomingBroadcasts(completed: ([LiveBroadcastStreamModel]?) -> Void) {
      youTubeRequest.listBroadcasts("upcoming", completed: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completed: completed)
         } else {
            completed(nil)
         }
      })
   }

   private func fillList(broadcasts: LiveBroadcastListModel, completed: ([LiveBroadcastStreamModel]?) -> Void) {
      let items = broadcasts.items
      let sortedItems = items.sort({ JsonUtility.dateWithJSONString($0.snipped.publishedAt).compare(JsonUtility.dateWithJSONString($1.snipped.publishedAt)) == NSComparisonResult.OrderedDescending })
      completed(sortedItems)
   }
   
   func createBroadcast(title: String, description: String, startTime: NSDate, completed: (Bool) -> Void) {

      // Create Live broadcast
      let liveStreamDescription = "This stream was created by the YouTubeLiveVideo iOS application"
      let liveStreamName = "Test"
      
      youTubeRequest.createLiveBroadcast(title, startDateTime: startTime, completed: { liveLiveBroadcastStreamModel in
         if let liveBroadcast = liveLiveBroadcastStreamModel {
            // Create Live stream
            self.youTubeRequest.createLiveStream(title, description: liveStreamDescription, streamName: liveStreamName) { liveStream in
               if let liveStream = liveStream {
                  // Bind live stream
                  self.youTubeRequest.bindLiveBroadcast(broadcastId: liveBroadcast.id, liveStreamId: liveStream.id, completed: { liveBroadcast in
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
   
   func startBroadcast(broadcast: LiveBroadcastStreamModel, completed: (Bool) -> Void) {
      let broadcastId = broadcast.id
      let liveStreamId = broadcast.contentDetails.boundStreamId
      if broadcastId.characters.count > 0 &&  liveStreamId.characters.count > 0 {
         youTubeRequest.getLiveBroadcast(broadcastId: broadcastId) { liveBroadcast in
            if let liveBroadcast = liveBroadcast {
               self.youTubeRequest.getLiveStream(liveStreamId, completed: { liveStream in
                  if let liveStream = liveStream {
                     self.youTubePresenter.showVideoStreamViewController(liveStream, liveBroadcast: liveBroadcast, completed: {
                     })
                  }
               })
            } else {
               print("Something went wrong")
            }
         }
      } else {
         print("Something went wrong")
      }
   }
   
}

// MARK: Utils

extension YouTubeLiveStreamingWorker {
   
   private func deleteAllBroadcasts(completed: (Bool) -> Void) {
      youTubeRequest.listBroadcasts("all", completed: { broadcastList in
         if let broadcastList = broadcastList {
            let items = broadcastList.items
            self.deleteBroadcast(items, index: 0, completed: completed)
         } else {
            completed(false)
         }
      })
   }
   
   private func deleteBroadcast(items: [LiveBroadcastStreamModel], index: Int, completed: (Bool) -> Void) {
      if index < items.count {
         let item = items[index]
         let broadcastId = item.id
         youTubeRequest.deleteLiveBroadcast(broadcastId: broadcastId, completed: { success in
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

extension YouTubeLiveStreamingWorker {
   
   func testUpdateLiveStream() {
      let liveStreamId = "0"
      let title = "Live Stream"
      let format = "1080p"    // 1080p 1440p 240p 360p 480p 720p
      let ingestionType = "rtmp" // dash rtmp
      youTubeRequest.updateLiveStream(liveStreamId, title: title, format: format, ingestionType: ingestionType, completed: { success in
         
         if success {
            print("All right")
         } else {
            print("Something went wrong")
         }
         
      })
   }
   
}
