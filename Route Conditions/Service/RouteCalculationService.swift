//
//  RouteCalculationService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation
import CoreLocation

class RouteCalculationService {
    
    static let shared = RouteCalculationService()
    
    private init() { }
    
    /// Speed in meters per second
    func calculateRoute(existingWaypoints: [CustomWaypoint], speed: Double, unit: UnitSpeed, departureTime: Date, timeInterval: TimeInterval) -> [WeatherWaypoint] {
        guard existingWaypoints.count != 0 else { return [] }
        
        var waypoints: [WeatherWaypoint] = []
        let waypointCount = existingWaypoints.count
        var currentTime = departureTime
        let averageSpeed = Measurement(value: speed, unit: unit).converted(to: .metersPerSecond).value
        
        // Add start point
        let first = existingWaypoints.first!
        let startPoint = WeatherWaypoint(coordinate: first.coordinate, position: 0, date: departureTime)
        waypoints.append(startPoint)
        
        for i in 0..<(waypointCount - 1) {
            let startWaypoint = existingWaypoints[i]
            let endWaypoint = existingWaypoints[i + 1]
            let distance = calculateDistance(start: startWaypoint, end: endWaypoint)
            let travelTime = distance / averageSpeed
            
            let waypointTimeInterval = timeInterval / 3600 // Convert seconds to hours
            let numberOfIntermediateWaypoints = Int(travelTime / waypointTimeInterval)
            
            guard numberOfIntermediateWaypoints > 0 else { continue }
            
            for j in 1...numberOfIntermediateWaypoints {
                let ratio = Double(j) / Double(numberOfIntermediateWaypoints)
                let latitude = startWaypoint.latitude + (endWaypoint.latitude - startWaypoint.latitude) * ratio
                let longitude = startWaypoint.longitude + (endWaypoint.longitude - startWaypoint.longitude) * ratio
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let time = currentTime.addingTimeInterval(TimeInterval(j) * timeInterval)
                let waypoint = WeatherWaypoint(coordinate: coordinate, position: i+j, date: time)
                waypoints.append(waypoint)
            }
            
            currentTime = currentTime.addingTimeInterval((travelTime * 3600) + timeInterval) // Convert hours to seconds and add timeInterval
        }
        
        for waypoint in waypoints {
            print(waypoint.date)
        }
        
        return waypoints
    }
    
    private func calculateDistance(start: HasCoordinate, end: HasCoordinate) -> Double {
        let earthRadius = Constants.RouteCalculation.earthRadius // Earth's radius in kilometers
        
        let startLatitudeRadians = start.coordinate.latitude * .pi / 180
        let startLongitudeRadians = start.coordinate.longitude * .pi / 180
        let endLatitudeRadians = end.coordinate.latitude * .pi / 180
        let endLongitudeRadians = end.coordinate.longitude * .pi / 180
        
        let deltaLatitude = endLatitudeRadians - startLatitudeRadians
        let deltaLongitude = endLongitudeRadians - startLongitudeRadians
        
        let a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) + cos(startLatitudeRadians) * cos(endLatitudeRadians) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c
        
        return distance
    }
}
