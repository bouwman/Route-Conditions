//
//  Route_ConditionsTests.swift
//  Route ConditionsTests
//
//  Created by Tassilo Bouwman on 13.06.23.
//

import XCTest
@testable import Route_Conditions

class RouteCalculationServiceTests: XCTestCase {
    var routeCalculationService: RouteCalculationService!

    override func setUp() {
        super.setUp()
        routeCalculationService = RouteCalculationService()
    }

    override func tearDown() {
        routeCalculationService = nil
        super.tearDown()
    }

    func testCalculateRoute() {
        let vehicle = Vehicle(id: UUID(), name: "Car", averageSpeed: 100)
        
        let london = Waypoint(latitude: 51.5074, longitude: -0.1278, time: Date())
        let manchester = Waypoint(latitude: 53.4808, longitude: -2.2426, time: Date())
        let edinburgh = Waypoint(latitude: 55.9533, longitude: -3.1883, time: Date())
        
        let inputRoute = Route(name: "UK Trip")
        
        inputRoute.waypoints = [london, manchester, edinburgh]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let departureTime = dateFormatter.date(from: "2023/06/14 10:00")!
        
        let timeInterval: TimeInterval = 30 * 60 // 30 minutes in seconds
        
        let calculatedRoute = routeCalculationService.calculateRoute(vehicle: vehicle, inputRoute: inputRoute.waypoints, departureTime: departureTime, timeInterval: timeInterval)
        
        XCTAssertEqual(calculatedRoute.count, 16, "The number of waypoints should be 16")
        
        let expectedTimes = [
            "2023/06/14 10:00",
            "2023/06/14 10:30",
            "2023/06/14 11:00",
            "2023/06/14 11:30",
            "2023/06/14 12:00",
            "2023/06/14 12:30",
            "2023/06/14 13:00",
            "2023/06/14 13:12",
            "2023/06/14 13:30",
            "2023/06/14 14:00",
            "2023/06/14 14:30",
            "2023/06/14 15:00",
            "2023/06/14 15:30",
            "2023/06/14 16:00",
            "2023/06/14 16:30",
            "2023/06/14 16:42"
        ]
        
        for (index, waypoint) in calculatedRoute.enumerated() {
            let expectedTime = dateFormatter.date(from: expectedTimes[index])!
            XCTAssertEqual(waypoint.time, expectedTime, "The waypoint time at index \(index) should be \(expectedTimes[index])")
        }
    }
}

