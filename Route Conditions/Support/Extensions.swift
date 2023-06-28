//
//  Extensions.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 21.05.23.
//

import Foundation
import WeatherKit
import CoreLocation
import MapKit
import OSLog
import SwiftUI

extension CLLocation {
    
    func bearing(to destination: CLLocation) -> CLLocationDegrees {
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()
        let lat2 = destination.coordinate.latitude.toRadians()
        let lon2 = destination.coordinate.longitude.toRadians()
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing.toDegrees()
    }
    
    func destinationLocation(bearing: CLLocationDegrees, distance: CLLocationDistance) -> CLLocation {
        let radius = self.horizontalAccuracy + distance
        let radiansBearing = bearing.toRadians()
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()
        
        let lat2 = asin(sin(lat1) * cos(distance / radius) + cos(lat1) * sin(distance / radius) * cos(radiansBearing))
        let lon2 = lon1 + atan2(sin(radiansBearing) * sin(distance / radius) * cos(lat1), cos(distance / radius) - sin(lat1) * sin(lat2))
        
        return CLLocation(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }
}

extension CLLocationDegrees {
    func toRadians() -> CLLocationDegrees {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> CLLocationDegrees {
        return self * 180.0 / .pi
    }
}

extension Measurement<UnitSpeed>: Strideable {
    public func distance(to other: Measurement<UnitSpeed>) -> Double {
        self.value.distance(to: other.value)
    }
    
    public func advanced(by n: Double) -> Measurement<UnitSpeed> {
        let value = self.converted(to: .kilometersPerHour).value
        return Measurement<UnitSpeed>.init(value: value.advanced(by: n), unit: .kilometersPerHour)
    }
    
    public typealias Stride = Double
    
    
}

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    static let network = Logger(subsystem: subsystem, category: "network")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let widget = Logger(subsystem: subsystem, category: "widget")
}

private let measurementFormatter = MeasurementFormatter()

extension Measurement {
    func formatted() -> String {
        measurementFormatter.string(from: self)
    }
}

extension WeatherKit.Wind.CompassDirection {
    static func from(degrees: Double) -> WeatherKit.Wind.CompassDirection {
        switch degrees {
        case 0..<22.5, 337.5...360:
            return .north
        case 22.5..<67.5:
            return .northNortheast
        case 67.5..<112.5:
            return .northeast
        case 112.5..<157.5:
            return .eastNortheast
        case 157.5..<202.5:
            return .east
        case 202.5..<247.5:
            return .eastSoutheast
        case 247.5..<292.5:
            return .southeast
        case 292.5..<337.5:
            return .southSoutheast
        default:
            print("Value is not a degree: \(degrees)")
            return .north
        }
    }
}

extension WeatherKit.Wind.CompassDirection {
    var imageName: String {
        switch self {
        case .north, .northNortheast, .northNorthwest:
            return "arrow.up"
        case .northeast:
            return "arrow.up.right"
        case .east, .eastNortheast, .eastSoutheast:
            return "arrow.right"
        case .southeast:
            return "arrow.down.right"
        case .south, .southSoutheast, .southSouthwest:
            return "arrow.down"
        case .southwest:
            return "arrow.down.left"
        case .west, .westNorthwest, .westSouthwest:
            return "arrow.left"
        case .northwest:
            return "arrow.up.left"
        }
    }
}

extension UnitSpeed {
    static var all: [UnitSpeed] {
        [.kilometersPerHour, .milesPerHour, .knots]
    }
    
    var title: String {
        measurementFormatter.string(from: self)
    }
}

extension UnitSpeed: Identifiable {
    public var id: UnitSpeed {
        switch self {
        case .kilometersPerHour:
                .kilometersPerHour
        case .knots:
                .knots
        case .milesPerHour:
                .milesPerHour
        case .metersPerSecond:
                .metersPerSecond
        default:
            fatalError("Unsupported Unit")
        }
    }
}

infix operator ~<=
infix operator ~==
infix operator ~>=

extension Double {

    static func ~<= (lhs: Double, rhs: Double) -> Bool {
        (lhs < rhs) || (lhs ~== rhs)
    }

    static func ~>= (lhs: Double, rhs: Double) -> Bool {
        (lhs > rhs) || (lhs ~== rhs)
    }

    static func ~== (lhs: Double, rhs: Double) -> Bool {
        abs(lhs - rhs) < 0.0001
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        let allowedDelta = 0.01
        let isLongEqual = abs(lhs.longitude - rhs.longitude) < allowedDelta
        let isLatiEqual = abs(lhs.latitude - rhs.latitude) < allowedDelta
        
        return isLongEqual && isLatiEqual
    }
}

let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 3
    formatter.numberStyle = .decimal
    return formatter
}()

extension CLLocationCoordinate2D: CustomStringConvertible {
    public var description: String {
        "(" + latitude.decimalString() + ", " + longitude.decimalString() + ")"
    }
}

extension Double {
    public func decimalString() -> String {
        decimalFormatter.string(from: self as NSNumber) ?? "-.-"
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension Date {
    func isWithinSameHour(as date: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.hour], from: self, to: date)
        return diff.hour! == 0
    }
}

extension Date {
    static var threeDaysFromToday: ClosedRange<Date> {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date.now)
        let end = cal.date(byAdding: .day, value: 4, to: start)!
        
        return start...end
    }
    
    static var threeDaysFromTodayTimeInterval: ClosedRange<Double> {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date.now)
        let end = cal.date(byAdding: .day, value: 4, to: start)!
        
        return start.timeIntervalSince1970...end.timeIntervalSince1970
    }
}

extension Double {
    func asTimeString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? ""
    }
}

extension BinaryFloatingPoint {
    func asTimeString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self)) ?? "" //formatter.string(from: self) ?? ""
    }
}

extension Measurement {
    static func optional(value: Double?, unit: UnitType) -> Measurement<UnitType>? {
        guard let value else {
            return nil
        }
        return Measurement(value: value, unit: unit)
    }
}

