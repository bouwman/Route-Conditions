//
//  File.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 23.06.23.
//

import Foundation

enum RouteError: Error {
    case unexpected(error: Error)
    case networkStatus(code: String)
    case custom(description: String)
    case unknown
}

extension RouteError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "RouteError")
        case .unexpected(error: let error):
            return error.localizedDescription
        case .networkStatus(code: let code):
            return NSLocalizedString("Network error. Status: " + code, comment: "RouteError")
        case .custom(description: let description):
            return NSLocalizedString(description, comment: "RouteError")
        }
    }
}
