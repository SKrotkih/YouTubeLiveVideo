//
//  LiveBroadcastListModel.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

// {
//     etag = "\"I_8xdZu766_FSaexEaDXTIfEWc0/SN8GQwjsPoYTifHs6t68KKesjic\"";
//     items =     (
//                 {
//             etag = "\"I_8xdZu766_FSaexEaDXTIfEWc0/jI_VrrBo5bhpU24nvct4fYITSn8\"";
//             id = "GalQUodF5-o";
//             kind = "youtube//liveBroadcast";
//             snippet =             {
//                 channelId = UCm4xprzPvVL8Uravaneq7CA;
//                 description = "";
//                 isDefaultBroadcast = 0;
//                 liveChatId = Cg0KC0dhbFFVb2RGNS1v;
//                 publishedAt = "2016-10-16T05:04:46.000Z";
//                 scheduledStartTime = "2016-10-16T05:09:44.000Z";
//                 thumbnails =                 {
//                     default =                     {
//                         height = 90;
//                         url = "https://i.ytimg.com/vi/GalQUodF5-o/default_live.jpg";
//                         width = 120;
//                     };
//                     high =                     {
//                         height = 360;
//                         url = "https://i.ytimg.com/vi/GalQUodF5-o/hqdefault_live.jpg";
//                         width = 480;
//                     };
//                     medium =                     {
//                         height = 180;
//                         url = "https://i.ytimg.com/vi/GalQUodF5-o/mqdefault_live.jpg";
//                         width = 320;
//                     };
//                 };
//                 title = "My test live broadcast";
//             };
//         },
//                 {
//             etag = "\"I_8xdZu766_FSaexEaDXTIfEWc0/8pnvseMzc_o1h2WI8B-0SJAcDR4\"";
//             id = "sGCYiZ-ycK8";
//             kind = "youtube//liveBroadcast";
//             snippet =             {
//                 channelId = UCm4xprzPvVL8Uravaneq7CA;
//                 description = "";
//                 isDefaultBroadcast = 0;
//                 publishedAt = "2016-10-15T18:04:47.000Z";
//                 scheduledStartTime = "2016-10-15T18:09:46.000Z";
//                 thumbnails =                 {
//                     default =                     {
//                         height = 90;
//                         url = "https://i.ytimg.com/vi/sGCYiZ-ycK8/default_live.jpg";
//                         width = 120;
//                     };
//                     high =                     {
//                         height = 360;
//                         url = "https://i.ytimg.com/vi/sGCYiZ-ycK8/hqdefault_live.jpg";
//                         width = 480;
//                     };
//                     medium =                     {
//                         height = 180;
//                         url = "https://i.ytimg.com/vi/sGCYiZ-ycK8/mqdefault_live.jpg";
//                         width = 320;
//                     };
//                 };
//                 title = Broadcast;
//             };
//         },
//                 {
//             etag = "\"I_8xdZu766_FSaexEaDXTIfEWc0/MHL4lOvtbXAqX4bpuC9k_fFzJyA\"";
//             id = U8O8er6neBY;
//             kind = "youtube//liveBroadcast";
//             snippet =             {
//                 channelId = UCm4xprzPvVL8Uravaneq7CA;
//                 description = "";
//                 isDefaultBroadcast = 0;
//                 publishedAt = "2016-10-15T17:56:57.000Z";
//                 scheduledStartTime = "2016-10-15T18:01:24.000Z";
//                 thumbnails =                 {
//                     default =                     {
//                         height = 90;
//                         url = "https://i.ytimg.com/vi/U8O8er6neBY/default_live.jpg";
//                         width = 120;
//                     };
//                     high =                     {
//                         height = 360;
//                         url = "https://i.ytimg.com/vi/U8O8er6neBY/hqdefault_live.jpg";
//                         width = 480;
//                     };
//                     medium =                     {
//                         height = 180;
//                         url = "https://i.ytimg.com/vi/U8O8er6neBY/mqdefault_live.jpg";
//                         width = 320;
//                     };
//                 };
//                 title = Broadcast;
//             };
//         }
//     );
//     kind = "youtube//liveBroadcastListResponse";
//     pageInfo =     {
//         resultsPerPage = 5;
//         totalResults = 3;
//     };
// }


public struct LiveBroadcastListModel {

   public struct Item {
      let etag: String
      let id: String
      let kind: String
      let snippet: Snipped
      let status: Status
   }
   
   public struct Status {
      let lifeCycleStatus: String
      let recordingStatus: String
      let privacyStatus: String
   }
   
   public struct Snipped {
      let publishedAt: String
      let channelId: String
      let description: String
      let isDefaultBroadcast: Int
      let scheduledStartTime: NSDate
      let title: String
      let thumbnails: Thumbnails
   }

   public struct Thumbnail {
      let height: Int
      let url: String
      let width: Int
   }
   
   public struct Thumbnails {
      let def: Thumbnail
      let height: Thumbnail
      let medium: Thumbnail
   }
   
   public struct PageInfo {
      let resultsPerPage: Int
      let totalResults: Int
   }
   let etag: String
   let kind: String
   let pageInfo: PageInfo
   let items: [LiveBroadcastStreamModel]
}

// MARK: - Decodable

extension LiveBroadcastListModel: Decodable {
   public static func decode(json: JSON) -> LiveBroadcastListModel {
      let pageInfo = LiveBroadcastListModel.PageInfo.decode(json["pageInfo"])
      var items: [LiveBroadcastStreamModel] = []
      if let content = json["items"].array {
         for item in content {
            let contentItem = LiveBroadcastStreamModel.decode(item)
            items.append(contentItem)
         }
      }
      let model = LiveBroadcastListModel(
         etag: json["etag"].stringValue,
         kind: json["kind"].stringValue,
         pageInfo: pageInfo,
         items: items
      )
      return model
   }
}

extension LiveBroadcastListModel.Item {
   public static func decode(json: JSON) -> LiveBroadcastListModel.Item {
      let snippet = LiveBroadcastListModel.Snipped.decode(json["snippet"])
      let status = LiveBroadcastListModel.Status.decode(json["status"])
      let model = LiveBroadcastListModel.Item (
         etag: json["etag"].stringValue,
         id: json["id"].stringValue,
         kind: json["kind"].stringValue,
         snippet: snippet,
         status: status
      )
      return model
   }
}

extension LiveBroadcastListModel.Status {
   public static func decode(json: JSON) -> LiveBroadcastListModel.Status {
      let model = LiveBroadcastListModel.Status (
         lifeCycleStatus: json["lifeCycleStatus"].stringValue,
         recordingStatus: json["recordingStatus"].stringValue,
         privacyStatus: json["privacyStatus"].stringValue
      )
      return model
   }
}

extension LiveBroadcastListModel.PageInfo {
   public static func decode(json: JSON) -> LiveBroadcastListModel.PageInfo {
      let model = LiveBroadcastListModel.PageInfo (
         resultsPerPage: json["resultsPerPage"].intValue,
         totalResults: json["totalResults"].intValue
      )
      return model
   }
}

extension LiveBroadcastListModel.Snipped {
   public static func decode(json: JSON) -> LiveBroadcastListModel.Snipped {
      
      let thumbnails = LiveBroadcastListModel.Thumbnails.decode(json["thumbnails"])
      
      let model = LiveBroadcastListModel.Snipped (
         publishedAt: json["publishedAt"].stringValue,
         channelId: json["channelId"].stringValue,
         description: json["description"].stringValue,
         isDefaultBroadcast: json["isDefaultBroadcast"].intValue,
         scheduledStartTime: JsonUtility.dateWithJSONString(json["scheduledStartTime"].stringValue),
         title: json["title"].stringValue,
         thumbnails: thumbnails
      )
      return model
   }
}

extension LiveBroadcastListModel.Thumbnails {
   
   //                 thumbnails =                 {
   //                     default =                     {
   //                         height = 90;
   //                         url = "https://i.ytimg.com/vi/U8O8er6neBY/default_live.jpg";
   //                         width = 120;
   //                     };
   //                     high =                     {
   //                         height = 360;
   //                         url = "https://i.ytimg.com/vi/U8O8er6neBY/hqdefault_live.jpg";
   //                         width = 480;
   //                     };
   //                     medium =                     {
   //                         height = 180;
   //                         url = "https://i.ytimg.com/vi/U8O8er6neBY/mqdefault_live.jpg";
   //                         width = 320;
   //                     };
   //                 };
   
   public static func decode(json: JSON) -> LiveBroadcastListModel.Thumbnails {
      let def = LiveBroadcastListModel.Thumbnail.decode(json["default"])
      let height = LiveBroadcastListModel.Thumbnail.decode(json["high"])
      let medium = LiveBroadcastListModel.Thumbnail.decode(json["medium"])
      
      let model = LiveBroadcastListModel.Thumbnails (
         def: def,
         height: height,
         medium: medium
      )
      return model
   }
}

extension LiveBroadcastListModel.Thumbnail {
   public static func decode(json: JSON) -> LiveBroadcastListModel.Thumbnail {
      let model = LiveBroadcastListModel.Thumbnail (
         height: json["height"].intValue,
         url: json["url"].stringValue,
         width: json["width"].intValue
      )
      return model
   }
}
