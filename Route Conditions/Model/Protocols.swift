//
//  Protocols.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation

protocol Waypoint {
    var position: Int { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
}

protocol DirectionalData {
    var directionData: Double? { get set }
}

protocol SpeedableData {
    var speedData: Double? { get set }
}

protocol HeightableData {
    var heightData: Double? { get set }
}

protocol WindModelConvertible {
    /// Speed in km/h
    var convertedWindSpeed: Double? { get }
    
    /// Direction in degrees
    var convertedWindDirection: Double? { get }
    
    /// Speed in km/h
    var convertedWindGust: Double? { get }
}

protocol CurrentModelConvertible {
    /// Speed in km/h
    var convertedCurrentSpeed: Double? { get }
    
    /// Direction in degrees
    var convertedCurrentDirection: Double? { get }
}

protocol WaveModelConvertible {
    /// Height in meters
    var convertedWaveHeight: Double? { get }
    
    /// Direction in degrees
    var convertedWaveDirection: Double? { get }
}

protocol ConditionsModelConvertible {
    /// String desribing the contions, e.g. Sunny
    var convertedConditionsTitle: String? { get }
    
    /// SF Symbol, eg. sun.full
    var convertedConditionsSymbol: String? { get }
}

protocol TimeModelConvertible {
    /// True if it's during daylight
    var convertedTimeIsDaylight: Bool? { get }
}


protocol WeatherModelConvertible: WindModelConvertible, WaveModelConvertible, CurrentModelConvertible, ConditionsModelConvertible, TimeModelConvertible {
    /// Time of the forecast
    var convertedDate: Date { get }
}
