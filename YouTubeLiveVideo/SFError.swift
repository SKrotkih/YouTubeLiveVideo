//
//  SFError.swift
//  ParkingBuddy
//
//  Created by Sergey Krotkih on 20/08/2015.
//  Copyright (c) 2015 Coded.dk. All rights reserved.
//

import UIKit

enum SFError: ErrorType {
    case NetworkError(message: String)
    case HttpError(statusCode: Int, statusText: String, message: String?)
    case AuthError(message: String)
    case LogicError(message: String)
    case NoInternetError()
    
    func message() -> String {
        switch self {
        case .NetworkError(let message):
            return message
        case .HttpError(let statusCode, let statusText, let message):
            return message ?? "\(statusCode): \(statusText)"
        case .AuthError(let message):
            return message
        case .LogicError(let message):
            return message
        case .NoInternetError:
            return "Please check your connection and try again."
        }
    }
}
