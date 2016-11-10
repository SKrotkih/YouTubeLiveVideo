//
//  DateConverter.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class DateConverter: NSObject {

   class func dateEvent(_ datetime: Int64) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd MMMM\n19:mm"
      dateFormatter.locale = Locale(identifier: "ru")
      let text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(datetime) / 1000))
      return text
   }
   
   class func dateTimeBegin(_ datetime: Int64) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd MMMM HH:mm"
      let dt = Double(datetime) / 1000
      dateFormatter.locale = Locale(identifier: "ru")
      let text = dateFormatter.string(from: Date(timeIntervalSince1970: dt))
      return text
   }

   class func dateAfter(_ date: Date, after: (hour: NSInteger, minute: NSInteger, second: NSInteger)) -> Date {
      let calendar = Calendar.current
      if let date = (calendar as NSCalendar).date(byAdding: .hour, value: after.hour, to: date, options: []) {
         if let date = (calendar as NSCalendar).date(byAdding: .minute, value: after.minute, to: date, options: []) {
            if let date = (calendar as NSCalendar).date(byAdding: .second, value: after.second, to: date, options: []) {
               return date
            }
         }
      }
      return date
   }
   
}
