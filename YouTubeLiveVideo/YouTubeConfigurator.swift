//
//  YouTubeConfigurator.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class YouTubeConfigurator: NSObject {
   
   func configure(viewController: ViewController) {
      
      let worker = YouTubeLiveStreamingWorker()
      let requests = YouTubeLiveStreamingRequest()
      let presenter = YouTubeLiveStreamingPresenter()
      
      viewController.input = worker
      
      worker.youTubeRequest = requests
      worker.youTubePresenter = presenter
      
      presenter.youTubeRequest = requests
      presenter.viewController = viewController
   }
}

