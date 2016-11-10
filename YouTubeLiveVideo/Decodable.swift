//
//  Decodable.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol Decodable {
  static func decode(_ json: JSON) -> Self
}
