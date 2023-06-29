//
//  Protocols.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 24.06.23.
//

import Foundation
import CoreLocation
import SwiftUI

protocol HasLocation {
    var latitude: Double { get }
    var longitude: Double { get }
}

protocol HasCoordinate {
    var coordinate: CLLocationCoordinate2D { get }
}

protocol Waypointable: HasLocation {
    var position: Int { get set }
}

protocol Directional {
    var direction: Measurement<UnitAngle>? { get }
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

protocol SolarModelConvertible {
    /// True if it's during daylight
    var convertedSolarIsDaylight: Bool? { get }
}


protocol WeatherModelConvertible: WindModelConvertible, WaveModelConvertible, CurrentModelConvertible, ConditionsModelConvertible, SolarModelConvertible {
    /// Time of the forecast
    var convertedDate: Date { get }
}

protocol ColorScalable {
    var scaleColor: Color { get }
}
