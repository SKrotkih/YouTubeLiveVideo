//
//  SFError.swift
//  ParkingBuddy
//
//  Created by Sergey Krotkih on 20/08/2015.
//  Copyright (c) 2015 Coded.dk. All rights reserved.
//

import UIKit

enum SFError: Error {
    case networkError(message: String)
    case httpError(statusCode: Int, statusText: String, message: String?)
    case authError(message: String)
    case logicError(message: String)
    case noInternetError()
    
    func message() -> String {
        switch self {
        case .networkError(let message):
            return message
        case .httpError(let statusCode, let statusText, let message):
            return message ?? "\(statusCode): \(statusText)"
        case .authError(let message):
            return message
        case .logicError(let message):
            return message
        case .noInternetError:
            return "Please check your connection and try again."
        }
    }
}
