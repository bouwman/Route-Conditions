//
//  Model+Extensions.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 18.06.23.
//

import Foundation
import CoreLocation
import MapKit

protocol Waypoint {
    var position: Int { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
}

extension Waypoint {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension WeatherWaypoint {
    var currentWeather: WeatherData? {
        let sort = weather.sorted { $0.date < $1.date }
        let first = sort.first { $0.date.timeIntervalSince(time) > 0 }
        
        return first
    }
}


let measurementFormatter = MeasurementFormatter()

extension Measurement {
    var string: String {
        measurementFormatter.string(from: self)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

extension WeatherData {
    var dateString: String {
        dateFormatter.string(from: date)
    }
}

extension TimeData {
    var daylightSymbolName: String {
        isDaylight ? "sun.max" : "moon.stars"
    }
    
    // TODO: Use NSLocalizedString
    var description: String {
        isDaylight ? "Day" : "Night"
    }
}

extension WeatherWaypoint {
    var dateString: String {
        dateFormatter.string(from: time)
    }
}

extension Collection where Element: Waypoint {
    var mapRect: MKMapRect {
        // let mapEdgePadding = UIEdgeInsets(top: 70, left: 70, bottom: 70, right: 70)
        var zoomRect = MKMapRect.null

        for annotation in self {
            let aPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
                
        return zoomRect
    }
    
    var region: MKCoordinateRegion {
        var region = MKCoordinateRegion(mapRect)
        
        region.span.latitudeDelta += 5
        region.span.longitudeDelta += 5
        
        return region
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        map { $0.coordinate }
    }
    
    var points: [MKMapPoint] {
        map { MKMapPoint($0.coordinate) }
    }
}