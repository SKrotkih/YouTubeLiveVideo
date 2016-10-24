//
//  ViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   @IBOutlet weak var tableView: UITableView!
   
   var refreshControl: UIRefreshControl!
   
   var input: YouTubeLiveStreamingWorker!
   
   var upcoming = [LiveBroadcastStreamModel]()
   var current = [LiveBroadcastStreamModel]()
   var past = [LiveBroadcastStreamModel]()
   
   private var completedThreadsCount: Int = 0
   
   override func viewDidLoad() {
      super.viewDidLoad()

      let configurator = YouTubeConfigurator()
      configurator.configure(self)

      setUpRefreshControl()
      
      loadData()
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }

   @IBAction func createBroadcastButtonTapped(sender: AnyObject) {
      let title = "Live video"
      let description = "Test broadcast video"
      let startDate = DateConverter.dateAfter(NSDate(), after: (hour: 0, minute: 2, second: 0))
      
      Alert.sharedInstance.showConfirmCancel("YouTube Live Streaming API", message: "You realy want to create a new Live broadcast video?", onConfirm: {
         self.input.createBroadcast(title, description: description, startTime: startDate, completed: { success in
            if success {
               Alert.sharedInstance.showOk("Done", message: "Please, refresh the table after pair seconds")
            } else {
               Alert.sharedInstance.showOk("Sorry", message: "Something went wrong")
            }
         })
      })
   }

}

extension ViewController {
   
   private func loadData() {
      completedThreadsCount = 0
      input.getUpcomingBroadcasts(){ streams in
         self.applyStreams("upcoming", streams: streams)
      }
      input.getActiveBroadcasts(){ streams in
         self.applyStreams("current", streams: streams)
      }
      input.getCompletedBroadcasts(){ streams in
         self.applyStreams("past", streams: streams)
      }
   }
   
   private func applyStreams(type: String, streams: [LiveBroadcastStreamModel]?) {
      completedThreadsCount += 1
      if let broadcasts = streams {
         if type == "upcoming" {
            self.upcoming = self.upcoming + broadcasts
         } else if type == "current" {
            self.current = self.current + broadcasts
         } else if type == "past" {
            self.past = self.past + broadcasts
         }
      }
      if completedThreadsCount == 3 {
         self.tableView.reloadData()
      }
   }
   
}

// MARK: Refresh Control

extension ViewController {
   
   private func setUpRefreshControl() {
      self.refreshControl = UIRefreshControl()
      self.refreshControl.attributedTitle = NSAttributedString(string: "Pull down and release for updating table data source", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
      self.refreshControl.tintColor = UIColor.redColor()
      self.refreshControl.addTarget(self, action: #selector(ViewController.refreshData(_:)), forControlEvents: UIControlEvents.ValueChanged)
      self.tableView.addSubview(refreshControl)
   }
   
   func refreshData(sender: AnyObject) {
      self.refreshControl.endRefreshing()
      refreshData()
   }
   
   private func refreshData() {
      self.upcoming.removeAll()
      self.current.removeAll()
      self.past.removeAll()
      dispatch_async(dispatch_get_main_queue(), {
         self.tableView.reloadData()
      })
      self.loadData()
   }
   
}

// MARK: UiTableView delegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 3
   }
   
   func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      switch section {
      case 0:
         return "Upcoming"
      case 1:
         return "Live now"
      case 2:
         return "Completed"
      default:
         assert(false, "Incorrect number of sections")
      }
   }
   
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0:
         return self.upcoming.count
      case 1:
         return self.current.count
      case 2:
         return self.past.count
      default:
         return 0
      }
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! TableViewCell
      var broadcast: LiveBroadcastStreamModel!
      switch indexPath.section {
      case 0:
         broadcast =  self.upcoming[indexPath.row]
      case 1:
         broadcast =  self.current[indexPath.row]
      case 2:
         broadcast =  self.past[indexPath.row]
      default:
         assert(false, "Incorrect number of sections")
      }
      let begin = broadcast.snipped.publishedAt
      cell.beginLabel.text = "start: \(begin)"
      
      cell.nameLabel.text = broadcast.snipped.title

      return cell
   }
   
   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      var broadcast: LiveBroadcastStreamModel!
      switch indexPath.section {
      case 0:
               broadcast = self.upcoming[indexPath.row]
               self.input.startBroadcast(broadcast, completed: { success in
                  if success {
                     self.refreshData()
                  }
               })
      case 1:
         broadcast = self.current[indexPath.row]
         YoutubeWorker.sharedInstance.playYoutubeID(broadcast.id, viewController: self)
      case 2:
         broadcast = self.past[indexPath.row]
         YoutubeWorker.sharedInstance.playYoutubeID(broadcast.id, viewController: self)
      default:
         assert(false, "Incorrect number of sections")
      }
      
   }
   
}

