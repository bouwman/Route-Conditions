//
//  File.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 23.06.23.
//

import Foundation

enum RouteError: Error {
    case missingData
    case creationError
    case batchInsertError
    case batchDeleteError
    case persistentHistoryChangeError
    case noFavouritesError
    case noStationSelected
    case stationNameEmpty
    case wrongDataFormat(error: Error)
    case customError(message: String)
    case networkError(error: Error)
    case unexpectedError(error: Error)
    
    enum Network: Error {
        case missingData
        case unexpected(error: Error)
    }
}
