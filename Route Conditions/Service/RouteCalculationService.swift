//
//  RouteCalculationService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation

class RouteCalculationService {
    func calculateRoute(vehicle: Vehicle, inputRoute: [CustomWaypoint], departureTime: Date, timeInterval: TimeInterval) -> [WeatherWaypoint] {
        var waypoints: [WeatherWaypoint] = []
        let waypointCount = inputRoute.count
        var currentTime = departureTime
        
        for i in 0..<(waypointCount - 1) {
            let startWaypoint = inputRoute[i]
            let endWaypoint = inputRoute[i + 1]
            let distance = calculateDistance(start: startWaypoint, end: endWaypoint)
            let travelTime = distance / vehicle.averageSpeed.converted(to: .metersPerSecond).value
            
            let waypointTimeInterval = timeInterval / 3600 // Convert seconds to hours
            let numberOfIntermediateWaypoints = Int(travelTime / waypointTimeInterval)
            
            for j in 0...numberOfIntermediateWaypoints {
                let ratio = Double(j) / Double(numberOfIntermediateWaypoints)
                let latitude = startWaypoint.latitude + (endWaypoint.latitude - startWaypoint.latitude) * ratio
                let longitude = startWaypoint.longitude + (endWaypoint.longitude - startWaypoint.longitude) * ratio
                let time = currentTime.addingTimeInterval(TimeInterval(j) * timeInterval)
                let waypoint = WeatherWaypoint(position: i+j, latitude: latitude, longitude: longitude, time: time)
                waypoints.append(waypoint)
            }
            
            currentTime = currentTime.addingTimeInterval((travelTime * 3600) + timeInterval) // Convert hours to seconds and add timeInterval
        }
        
        let finalWaypoint = WeatherWaypoint(position: waypoints.count + 1, latitude: inputRoute.last!.latitude, longitude: inputRoute.last!.longitude, time: currentTime)
        waypoints.append(finalWaypoint)
        
        return waypoints
    }
    
    private func calculateDistance(start: Waypoint, end: Waypoint) -> Double {
        let earthRadius = 6371.0 // Earth's radius in kilometers
        
        let startLatitudeRadians = start.latitude * .pi / 180
        let startLongitudeRadians = start.longitude * .pi / 180
        let endLatitudeRadians = end.latitude * .pi / 180
        let endLongitudeRadians = end.longitude * .pi / 180
        
        let deltaLatitude = endLatitudeRadians - startLatitudeRadians
        let deltaLongitude = endLongitudeRadians - startLongitudeRadians
        
        let a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) + cos(startLatitudeRadians) * cos(endLatitudeRadians) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c
        
        return distance
    }
}
