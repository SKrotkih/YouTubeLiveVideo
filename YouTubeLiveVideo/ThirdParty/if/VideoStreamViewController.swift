import UIKit
import AVFoundation

protocol VideoStreamViewControllerDelegate {
   func startPublishing(broadcast broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void)
   func finishPublishing(broadcast broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void)
   func cancelPublishing(broadcast broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void)
}

struct Preference {
   static var defaultInstance:Preference = Preference()
   var uri: String?
   var streamName: String?
}

final class VideoStreamViewController: UIViewController {
   
   var delegate: VideoStreamViewControllerDelegate?
   var livebroadcast: LiveBroadcastStreamModel?
   var scheduledStartTime: NSDate?
   private var timer: NSTimer?
   private var isPublishingInProcess: Bool = false
   private var publishingInterval: Double = 0
   
   private var rtmpConnection: RTMPConnection!
   private var rtmpStream: RTMPStream!
   private var sharedObject: RTMPSharedObject!
   private var httpService: HTTPService!
   private var httpStream: HTTPStream!
   
   private var lfView: GLLFView!
   private var publishButton: UIButton!
   private var currentFPSLabel: UILabel!
   private var currentStatusLabel: UILabel!
   private var timeLeftLabel: UILabel!
   private var closeButton: UIButton!
   
   private var currentPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Back

   // MARK:
   
   override func viewDidLoad() {
      super.viewDidLoad()

      setUpTransportProtocol()
      
      currentFPSLabel = UILabel()
      currentFPSLabel.textColor = UIColor.whiteColor()
      currentFPSLabel.backgroundColor = UIColor.clearColor()
      currentFPSLabel.text = ""
      view.addSubview(currentFPSLabel)

      currentStatusLabel = UILabel()
      currentStatusLabel.textColor = UIColor.whiteColor()
      currentStatusLabel.backgroundColor = UIColor.clearColor()
      currentStatusLabel.text = ""
      currentStatusLabel.textAlignment = .Right
      view.addSubview(currentStatusLabel)
      
      timeLeftLabel = UILabel()
      timeLeftLabel.textColor = UIColor.whiteColor()
      timeLeftLabel.backgroundColor = UIColor.clearColor()
      timeLeftLabel.text = ""
      timeLeftLabel.textAlignment = .Center
      view.addSubview(timeLeftLabel)
      
      closeButton = UIButton()
      closeButton.setImage(UIImage(named: "close_button"), forState: .Normal)
      closeButton.addTarget(self, action: #selector(VideoStreamViewController.closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
      view.addSubview(closeButton)
      
      navigationItem.rightBarButtonItems = [
         UIBarButtonItem(title: "Torch", style: .Plain, target: self, action: #selector(VideoStreamViewController.toggleTorch(_:))),
         UIBarButtonItem(title: "Camera", style: .Plain, target: self, action: #selector(VideoStreamViewController.rotateCamera(_:)))
      ]
      
      publishButton = UIButton()
      publishButton.backgroundColor = UIColor.redColor()
      publishButton.setTitle("●", forState: .Normal)
      publishButton.layer.masksToBounds = true
      publishButton.addTarget(self, action: #selector(VideoStreamViewController.onClickPublish(_:)), forControlEvents: .TouchUpInside)
      view.addSubview(publishButton)
      
      startTimer()
   }
   
   deinit {
      print("Deinit LiveViewControoler")
   }
   
   override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()

      lfView.frame = view.bounds
      let buttonSize: CGFloat = 44.0
      let boundsWidth = CGRectGetWidth(view.bounds)
      closeButton.frame = CGRect(x: (boundsWidth - 30.0) / 2.0, y: 15, width: 30.0, height: 30.0)
      publishButton.frame = CGRect(x: (boundsWidth - buttonSize) / 2.0, y: view.bounds.height - (buttonSize + 20.0), width: buttonSize, height: buttonSize)

      var x: CGFloat = 0.0
      currentFPSLabel.frame = CGRect(x: x, y: 50, width: 60, height: 30)
      x += 60.0
      currentStatusLabel.frame = CGRect(x: x, y: 50, width: boundsWidth - (x + 20.0), height: 30)
      timeLeftLabel.frame = CGRect(x: 0.0, y: view.bounds.height - (buttonSize + 20.0 + 40.0 + 10.0), width: boundsWidth, height: 40)
   }
   
   func rotateCamera(sender:UIBarButtonItem) {
      let position: AVCaptureDevicePosition = currentPosition == .Back ? .Front : .Back
      rtmpStream.attachCamera(DeviceUtil.deviceWithPosition(position))
      currentPosition = position
   }
   
   func toggleTorch(sender:UIBarButtonItem) {
      rtmpStream.torch = !rtmpStream.torch
   }
   
   func onClickPublish(sender: UIButton) {
      if (sender.selected) {
         changeState(publish: false, completed: { success in
            if success {
               sender.setTitle("●", forState: .Normal)
               sender.selected = !sender.selected
            }
         })
      } else {
         changeState(publish: true, completed: { success in
            sender.setTitle("■", forState: .Normal)
            sender.selected = !sender.selected
         })
      }
   }
   
   func changeState(publish publish: Bool, completed: (Bool) -> Void) {
      if (publish) {
         self.delegate?.startPublishing(broadcast: self.livebroadcast, completed: { success in
            if success {
               self.startPublishing()
               completed(true)
            } else {
               Alert.sharedInstance.showOk("System error", message: "Something went wrong. Please try it later.")
               completed(false)
            }
            
         })
      } else {
         self.finishPublishing()
         delegate?.finishPublishing(broadcast: self.livebroadcast, completed: { success in
            if success {
            }
         })
      }
   }
   
   override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
      if (NSThread.isMainThread()) {
         currentFPSLabel.text = "\(rtmpStream.currentFPS) fps"
      }
   }
   
   func showCurrentStatus(text: String) {
      currentStatusLabel.text = text
   }
   
   private func startTimer() {
      timer?.invalidate()
      timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
      NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
   }
   
   private func stopTimer() {
      timer?.invalidate()
      timer = nil
   }
   
   func updateCurrentTime() {
      guard let scheduledStartTime = self.scheduledStartTime else {
         timeLeftLabel.text = ""
         return
      }
      var timeInSec: Double = 0.0
      if isPublishingInProcess {
         publishingInterval += 1
         timeInSec = publishingInterval
      } else {
         timeInSec = scheduledStartTime.timeIntervalSinceNow
      }
      let hours = Int(timeInSec / 3600.0)
      timeInSec = timeInSec - Double(hours) * 3600.0
      let minutes = Int(timeInSec / 60)
      let seconds = Int(timeInSec - Double(minutes) * 60.0)
      timeLeftLabel.text = "\(hours) час, \(minutes) мин, \(seconds) сек"
   }
 
   func closeButtonPressed(sender: AnyObject) {
      if isPublishingInProcess {
         Alert.sharedInstance.showOkCancel("Трансляция живого видео", message: "Прервать трансляцию?", onComplete: {
            Alert.sharedInstance.showYesNo("Сохранить видео?", message: "Да - видео будет доступно для просмотра, Нет - видео будет удалено", onYes: {

               self.changeState(publish: false, completed: {_ in
                  
               })
               
               }, onNo: {
                  self.delegate?.cancelPublishing(broadcast: self.livebroadcast, completed: { success in
                  })
               })
            }, onCancel: {
         })
      } else {
         self.delegate?.cancelPublishing(broadcast: nil, completed: { success in
         })
      }
   }
   
}

// MARK: RTMP transport

extension VideoStreamViewController {
   
   private func setUpTransportProtocol() {
      rtmpConnection = RTMPConnection()
      rtmpStream = RTMPStream(rtmpConnection: rtmpConnection)
      rtmpStream.syncOrientation = true
      rtmpStream.attachAudio(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio))
      rtmpStream.attachCamera(DeviceUtil.deviceWithPosition(.Back))
      rtmpStream.addObserver(self, forKeyPath: "currentFPS", options: NSKeyValueObservingOptions.New, context: nil)
      rtmpStream.captureSettings = [
         "sessionPreset": AVCaptureSessionPreset1280x720,
         "continuousAutofocus": true,
         "continuousExposure": true,
      ]
      rtmpStream.videoSettings = [
         "width": 1280,
         "height": 720
      ]
      rtmpStream.captureSettings["fps"] = 60.0
      rtmpStream.audioSettings["bitrate"] = Float(RTMPStream.defaultAudioBitrate)
      rtmpStream.videoSettings["bitrate"] = Float(RTMPStream.defaultVideoBitrate)
      lfView = GLLFView(frame: CGRectZero)
      view.addSubview(lfView)
      lfView.attachStream(rtmpStream)
   }
   
   private func startPublishing() {
      guard let _ = Preference.defaultInstance.uri else {
         Alert.sharedInstance.showOk("Внутренняя ошибка", message: "Отстутсвует один из обязательных параметров!")
         return
      }
      UIApplication.sharedApplication().idleTimerDisabled = true
      rtmpConnection.addEventListener(Event.RTMP_STATUS, selector:#selector(VideoStreamViewController.rtmpStatusHandler(_:)), observer: self)
      rtmpConnection.connect(Preference.defaultInstance.uri!)
      isPublishingInProcess = true
      publishingInterval = 0.0
   }
   
   private func finishPublishing() {
      if isPublishingInProcess {
         UIApplication.sharedApplication().idleTimerDisabled = false
         rtmpConnection.removeEventListener(Event.RTMP_STATUS, selector:#selector(VideoStreamViewController.rtmpStatusHandler(_:)), observer: self)
         rtmpConnection.close()
         isPublishingInProcess = false
      }
   }
   
   func rtmpStatusHandler(notification:NSNotification) {
      let event: Event = Event.from(notification)
      if let data: ASObject = event.data as? ASObject, code: String = data["code"] as? String {
         
         print(code)
         
         switch code {
         case RTMPConnection.Code.ConnectSuccess.rawValue:
            
            print("RTMP: publish \(Preference.defaultInstance.uri!) - \(Preference.defaultInstance.streamName!)")
            
            rtmpStream!.publish(Preference.defaultInstance.streamName!)
         // sharedObject!.connect(rtmpConnection)
         default:
            break
         }
      }
   }

}

