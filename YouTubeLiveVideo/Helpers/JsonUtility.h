//
//  JsonUtility.h
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonUtility : NSObject

+ (NSDate*) dateWithJSONString: (NSString*) json;

@end
