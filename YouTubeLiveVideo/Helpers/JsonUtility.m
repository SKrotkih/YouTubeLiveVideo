//
//  JsonUtility.m
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

#import "JsonUtility.h"

@implementation JsonUtility


/*
 * take the current string and converts it into a manipulatable
 * NSDate object and then returns that object
 */
+ (NSDate*) dateWithJSONString: (NSString*) json {
   [NSDateFormatter setDefaultFormatterBehavior:
    NSDateFormatterBehavior10_4];
   NSDateFormatter *dateFormatter =
   [[NSDateFormatter alloc] init];
   
   [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
   [dateFormatter setTimeZone:[NSTimeZone
                               timeZoneForSecondsFromGMT:0]];
   [dateFormatter setCalendar:[[NSCalendar alloc]
                               initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
   
   NSDate *date = [[NSDate alloc] init];
   date = [dateFormatter dateFromString: json];
   return date;
}


@end
