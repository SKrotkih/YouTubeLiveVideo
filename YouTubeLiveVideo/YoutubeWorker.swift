//
//  YoutubeWorker.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class YoutubeWorker: NSObject {

   fileprivate var youtubePlayerViewController: YoutubePlayerViewController?
   
   class var sharedInstance: YoutubeWorker {
      struct SingletonWrapper {
         static let sharedInstance = YoutubeWorker()
      }
      return SingletonWrapper.sharedInstance;
   }
   
   fileprivate override init() {
      
      super.init()
   }
   
   func playYoutubeID(_ youtubeId: String, viewController: UIViewController) {
      if self.youtubePlayerViewController == nil {
         self.youtubePlayerViewController = YoutubePlayerViewController()
         self.youtubePlayerViewController!.delegate = self
      }
      youtubePlayerViewController!.playVideo(youtubeId, viewController: viewController)
   }
   
}

extension YoutubeWorker: YoutubePlayerDelegate {
   
   func playerDidFinish() {
      
   }
   
}
