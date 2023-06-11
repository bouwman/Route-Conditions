//
//  RouteCalculationService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation

import Foundation

class RouteCalculationService {
    var boat: Boat
    var route: Route
    
    init(boat: Boat) {
        self.boat = boat
        self.route = Route()
    }

    func calculatePredictedRoute() -> Route {
        var predictedRoute = Route()
        var currentTime = Date()
        let timeIntervalBetweenWaypoints: TimeInterval = 60 * 60 // 1 hour, for example

        for (index, waypoint) in route.waypoints.enumerated() {
            if let weather = getWeatherDataForWaypoint(waypoint: waypoint) {
                let boatSpeed = calculateBoatSpeedAtWaypoint(waypoint: waypoint, weather: weather)
                let estimatedTimeOfArrival = calculateEstimatedTimeOfArrival(waypoint: waypoint, boatSpeed: boatSpeed)
                let newWaypoint = Waypoint(latitude: waypoint.latitude, longitude: waypoint.longitude, time: estimatedTimeOfArrival, weather: weather)
                predictedRoute.waypoints.append(newWaypoint)

                if index < route.waypoints.count - 1 {
                    currentTime = estimatedTimeOfArrival
                    let nextWaypoint = route.waypoints[index + 1]

                    while currentTime < nextWaypoint.time {
                        currentTime += timeIntervalBetweenWaypoints
                        let newIntermediateWaypoint = calculateNewWaypoint(waypoint: waypoint, boatSpeed: boatSpeed, timeInterval: timeIntervalBetweenWaypoints)
                        if let intermediateWeather = getWeatherDataForWaypoint(waypoint: newIntermediateWaypoint) {
                            let intermediateWaypoint = Waypoint(latitude: newIntermediateWaypoint.latitude, longitude: newIntermediateWaypoint.longitude, time: currentTime, weather: intermediateWeather)
                            predictedRoute.waypoints.append(intermediateWaypoint)
                        }
                    }
                }
            }
        }

        return predictedRoute
    }


    private func calculateBoatSpeedAtWaypoint(waypoint: Waypoint, weather: WeatherData) -> Double {
        let windDirection = weather.windDirection
        let windSpeed = weather.windSpeed
        let oceanCurrentDirection = weather.oceanCurrentDirection
        let oceanCurrentSpeed = weather.oceanCurrentSpeed

        let windInfluenceFactorIndex = Int(windDirection / 360.0 * Double(boat.windInfluenceFactors.count))
        let windInfluenceFactor = boat.windInfluenceFactors[windInfluenceFactorIndex]

        let windEffect = windSpeed * windInfluenceFactor

        let boatDirection = calculateDirection(from: waypoint, to: waypoint) // Assuming the boat is moving in a straight line between waypoints
        let currentDirectionDifference = abs(boatDirection - oceanCurrentDirection)
        let currentEffect = oceanCurrentSpeed * cos(currentDirectionDifference * .pi / 180.0)

        let boatSpeed = boat.averageSpeed + windEffect + currentEffect
        return boatSpeed
    }
    
    private func calculateDirection(from startWaypoint: Waypoint, to endWaypoint: Waypoint) -> Double {
        let lat1 = startWaypoint.latitude * .pi / 180.0
        let lon1 = startWaypoint.longitude * .pi / 180.0
        let lat2 = endWaypoint.latitude * .pi / 180.0
        let lon2 = endWaypoint.longitude * .pi / 180.0

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)

        return (bearing * 180.0 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }


    private func calculateNewWaypoint(waypoint: Waypoint, boatSpeed: Double, timeInterval: TimeInterval) -> Waypoint {
        let distance = boatSpeed * timeInterval
        let bearing = calculateDirection(from: waypoint, to: waypoint) * .pi / 180.0

        let earthRadius = 6371.0 // Earth's radius in kilometers
        let angularDistance = distance / earthRadius

        let lat1 = waypoint.latitude * .pi / 180.0
        let lon1 = waypoint.longitude * .pi / 180.0

        let newLat = asin(sin(lat1) * cos(angularDistance) + cos(lat1) * sin(angularDistance) * cos(bearing))
        let newLon = lon1 + atan2(sin(bearing) * sin(angularDistance) * cos(lat1), cos(angularDistance) - sin(lat1) * sin(newLat))

        let newLatitude = newLat * 180.0 / .pi
        let newLongitude = newLon * 180.0 / .pi

        let newWaypoint = Waypoint(latitude: newLatitude, longitude: newLongitude, time: waypoint.time.addingTimeInterval(timeInterval), weather: waypoint.weather!)

        return newWaypoint
    }

    private func calculateEstimatedTimeOfArrival(waypoint: Waypoint, boatSpeed: Double) -> Date {
        let nextIndex = route.waypoints.firstIndex { $0 == waypoint }! + 1
        if nextIndex < route.waypoints.count {
            let nextWaypoint = route.waypoints[nextIndex]
            let distance = calculateDistance(from: waypoint, to: nextWaypoint)
            let timeToNextWaypoint = distance / boatSpeed
            return waypoint.time.addingTimeInterval(timeToNextWaypoint)
        } else {
            return waypoint.time
        }
    }
    
    private func getWeatherDataForWaypoint(waypoint: Waypoint) -> WeatherData? {
        let weatherService = RouteWeatherService()
        let weatherData = weatherService.getWeatherData(latitude: waypoint.latitude, longitude: waypoint.longitude, time: waypoint.time)
        return weatherData
    }
    
    private func calculateDistance(from startWaypoint: Waypoint, to endWaypoint: Waypoint) -> Double {
        let lat1 = startWaypoint.latitude * .pi / 180.0
        let lon1 = startWaypoint.longitude * .pi / 180.0
        let lat2 = endWaypoint.latitude * .pi / 180.0
        let lon2 = endWaypoint.longitude * .pi / 180.0

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        let earthRadius = 6371.0 // Earth's radius in kilometers
        return earthRadius * c
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
