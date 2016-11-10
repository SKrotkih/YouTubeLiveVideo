//
//  YouTubeConfigurator.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class YouTubeConfigurator: NSObject {
   
   func configure(_ viewController: ViewController) {
      
      let worker = YTLiveStreaming()
      let requests = LiveStreamingRequest()
      let presenter = Presenter()
      
      viewController.input = worker
      
      worker.youTubeRequest = requests
      
      presenter.youTubeRequest = requests
      presenter.viewController = viewController
   }
}

