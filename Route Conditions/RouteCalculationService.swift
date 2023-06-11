//
//  RouteCalculationService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 11.06.23.
//

import Foundation

class RouteCalculationService {
    var boat: Boat
    var route: Route
    var weatherForecast: WeatherForecast
    var weatherForecastService: MyWeatherService
    
    init(boat: Boat, route: Route, weatherForecast: WeatherForecast, weatherForecastService: MyWeatherService) {
        self.boat = boat
        self.route = route
        self.weatherForecast = weatherForecast
        self.weatherForecastService = weatherForecastService
    }
    
    func calculateRoute() -> [Waypoint] {
        var waypoints: [Waypoint] = []
        var previousWaypoint: Waypoint?
        
        for (index, waypoint) in route.waypoints.enumerated() {
            var estimatedTime: Date
            
            if let previousWaypoint = previousWaypoint {
                let timeInterval = calculateTimeInterval(previousWaypoint: previousWaypoint, currentWaypoint: waypoint)
                estimatedTime = Calendar.current.date(byAdding: .second, value: Int(timeInterval), to: previousWaypoint.time)!
            } else {
                estimatedTime = route.departureDate
            }
            
            let boatSpeed = calculateBoatSpeed(waypoint: waypoint, date: estimatedTime)
            let estimatedLocation = calculateEstimatedLocation(previousWaypoint: previousWaypoint, currentWaypoint: waypoint, totalSpeed: boatSpeed)
            let weatherForecast = calculateWeatherForecastAtWaypoint(waypoint: waypoint)
            
            let estimatedWaypoint = Waypoint(location: estimatedLocation, time: estimatedTime, weatherForecast: weatherForecast)
            waypoints.append(estimatedWaypoint)
            
            previousWaypoint = estimatedWaypoint
            
            if index == route.waypoints.count - 1 {
                let arrivalTime = Calendar.current.date(byAdding: .second, value: Int(calculateTimeInterval(previousWaypoint: estimatedWaypoint, currentWaypoint: waypoint)), to: estimatedWaypoint.time)!
                let finalWaypoint = Waypoint(location: waypoint.location, time: arrivalTime, weatherForecast: calculateWeatherForecastAtWaypoint(waypoint: waypoint))
                waypoints.append(finalWaypoint)
            }
        }
        
        return waypoints
    }

    
    func calculateWaypointTime(previousWaypoint: Waypoint?, currentWaypoint: Waypoint, totalSpeed: Double) -> Date {
        guard let previousWaypoint = previousWaypoint else {
            return currentWaypoint.time
        }
        
        let distance = calculateDistance(previousLocation: previousWaypoint.location, currentLocation: currentWaypoint.location)
        let timeInterval = distance / totalSpeed
        let estimatedTime = previousWaypoint.time.addingTimeInterval(timeInterval)
        
        return estimatedTime
    }
    
    func calculateBoatSpeed(waypoint: Waypoint, date: Date) -> Double {
        // TODO: Add time to forecast
        let weatherForecast = weatherForecastService.getWeatherForecast(location: waypoint.location, date: date)
        let windSpeed = weatherForecast.windSpeed
        let windDirection = weatherForecast.windDirection
        let currentSpeed = weatherForecast.oceanCurrentSpeed
        let currentDirection = weatherForecast.oceanCurrentDirection
        
        let windInfluence = calculateWindInfluenceAtWaypoint(waypoint: waypoint, windSpeed: windSpeed, windDirection: windDirection)
        let currentInfluence = calculateOceanCurrentInfluenceAtWaypoint(waypoint: waypoint, currentSpeed: currentSpeed, currentDirection: currentDirection)
        let boatSpeed = boat.averageSpeed * windInfluence * currentInfluence
        
        return boatSpeed
    }
    
    func calculateWindInfluenceAtWaypoint(waypoint: Waypoint, windSpeed: Double, windDirection: Double) -> Double {
        // TODO: Calculate wind influence
        return 1.0
    }
    
    func calculateOceanCurrentInfluenceAtWaypoint(waypoint: Waypoint, currentSpeed: Double, currentDirection: Double) -> Double {
        // TODO: Calculate current influence
        return 1.0
    }
    
    func calculateTimeInterval(previousWaypoint: Waypoint, currentWaypoint: Waypoint) -> TimeInterval {
        let distance = calculateDistance(previousLocation: previousWaypoint.location, currentLocation: currentWaypoint.location)
        let boatSpeed = calculateBoatSpeed(waypoint: currentWaypoint, date: currentWaypoint.time)
        let timeInterval = distance / boatSpeed
        
        return timeInterval
    }
    
    func calculateEstimatedLocation(previousWaypoint: Waypoint?, currentWaypoint: Waypoint, totalSpeed: Double) -> Location {
        guard let previousWaypoint = previousWaypoint else {
            return currentWaypoint.location
        }
        
        let distance = calculateDistance(previousLocation: previousWaypoint.location, currentLocation: currentWaypoint.location)
        let timeInterval = distance / totalSpeed
        let bearing = calculateBearing(previousLocation: previousWaypoint.location, currentLocation: currentWaypoint.location)
        let estimatedLocation = calculateLocationFromDistanceAndBearing(startLocation: previousWaypoint.location, distance: totalSpeed * timeInterval, bearing: bearing)
        
        return estimatedLocation
    }

    func calculateWeatherForecastAtWaypoint(waypoint: Waypoint) -> WeatherForecast {
        let weatherForecast = weatherForecastService.getWeatherForecast(location: waypoint.location, date: waypoint.time)
        return weatherForecast
    }
    
    func calculateDistance(previousLocation: Location, currentLocation: Location) -> Double {
        let previousLatitude = previousLocation.latitude.toRadians()
        let previousLongitude = previousLocation.longitude.toRadians()
        let currentLatitude = currentLocation.latitude.toRadians()
        let currentLongitude = currentLocation.longitude.toRadians()
        
        let deltaLatitude = currentLatitude - previousLatitude
        let deltaLongitude = currentLongitude - previousLongitude
        
        let a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) + cos(previousLatitude) * cos(currentLatitude) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = Constants.earthRadius * c
        
        return distance
    }
    
    func calculateBearing(previousLocation: Location, currentLocation: Location) -> Double {
        let previousLatitude = previousLocation.latitude.toRadians()
        let previousLongitude = previousLocation.longitude.toRadians()
        let currentLatitude = currentLocation.latitude.toRadians()
        let currentLongitude = currentLocation.longitude.toRadians()
        
        let deltaLongitude = currentLongitude - previousLongitude
        
        let y = sin(deltaLongitude) * cos(currentLatitude)
        let x = cos(previousLatitude) * sin(currentLatitude) - sin(previousLatitude) * cos(currentLatitude) * cos(deltaLongitude)
        
        let bearing = atan2(y, x)
        
        return (bearing.toDegrees() + 360.0).truncatingRemainder(dividingBy: 360.0)
    }
    
    func calculateLocationFromDistanceAndBearing(startLocation: Location, distance: Double, bearing: Double) -> Location {
        let startLatitude = startLocation.latitude.toRadians()
        let startLongitude = startLocation.longitude.toRadians()
        let angularDistance = distance / Constants.earthRadius
        let bearingRadians = bearing.toRadians()
        
        let endLatitude = asin(sin(startLatitude) * cos(angularDistance) + cos(startLatitude) * sin(angularDistance) * cos(bearingRadians))
        let endLongitude = startLongitude + atan2(sin(bearingRadians) * sin(angularDistance) * cos(startLatitude), cos(angularDistance) - sin(startLatitude) * sin(endLatitude))
        
        let latitude = endLatitude.toDegrees()
        let longitude = endLongitude.toDegrees()
        
        let location = Location(latitude: latitude, longitude: longitude)
        
        return location
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
