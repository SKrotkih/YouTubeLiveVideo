import UIKit
import XCDYouTubeKit

protocol YoutubePlayerDelegate {
   func playerDidFinish()
}

class YoutubePlayerViewController: UIViewController {
   var delegate: YoutubePlayerDelegate?
   var videoPlayerViewController: XCDYouTubeVideoPlayerViewController?
   private var currentRotation = "P"
   
   func playVideo(youtubeId: String, viewController: UIViewController) {
      self.videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: youtubeId)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(YoutubePlayerViewController.moviePlayerPlaybackDidFinish(_:)),
                                                       name: MPMoviePlayerPlaybackDidFinishNotification,
                                                       object: self.videoPlayerViewController!.moviePlayer)
      viewController.presentViewController(self.videoPlayerViewController!, animated: true) {
      }
   }
   
   func moviePlayerPlaybackDidFinish(notification: NSNotification) {
      NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
      if let finishReason: MPMovieFinishReason = notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]!.intValue as? MPMovieFinishReason {
         if finishReason == .PlaybackError {
            let error = notification.userInfo![XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey]
            print(error)
         }
      }
      delegate?.playerDidFinish()
   }
   
   func thumbnail(youtubeId: String) -> UIImage {
      let imageData = NSData(contentsOfURL: NSURL(string: "https://www.youtube.com/watch?v=\(youtubeId).jpg")!)
      return UIImage(data: imageData!)!
   }
}
