//
//  DateConverter.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class DateConverter: NSObject {

   class func dateEvent(datetime: Int64) -> String {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "dd MMMM\n19:mm"
      dateFormatter.locale = NSLocale(localeIdentifier: "ru")
      let text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(datetime) / 1000))
      return text
   }
   
   class func dateTimeBegin(datetime: Int64) -> String {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "dd MMMM HH:mm"
      let dt = Double(datetime) / 1000
      dateFormatter.locale = NSLocale(localeIdentifier: "ru")
      let text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: dt))
      return text
   }

   class func dateAfter(date: NSDate, after: (hour: NSInteger, minute: NSInteger, second: NSInteger)) -> NSDate {
      let calendar = NSCalendar.currentCalendar()
      if let date = calendar.dateByAddingUnit(.Hour, value: after.hour, toDate: date, options: []) {
         if let date = calendar.dateByAddingUnit(.Minute, value: after.minute, toDate: date, options: []) {
            if let date = calendar.dateByAddingUnit(.Second, value: after.second, toDate: date, options: []) {
               return date
            }
         }
      }
      return date
   }
   
}
