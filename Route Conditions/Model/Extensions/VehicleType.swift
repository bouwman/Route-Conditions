//
//  VehicleType.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 22.06.23.
//

import Foundation


let formatter: MeasurementFormatter = {
    let form = MeasurementFormatter()
    form.unitOptions = .providedUnit
    return form
}()

extension VehicleType {
    static var all: [VehicleType] {
        [.sailboat, .bicycle, .speedboat, .truck,  .car, .plane]
    }
    
    var imageName: String {
        switch self {
        case .plane:
            "airplane.departure"
        case .car:
            "car"
        case .truck:
            "truck.box"
        case .speedboat:
            "ferry"
        case .sailboat:
            "sailboat"
        case .bicycle:
            "bicycle"
        }
    }
    
    var defaultSpeed: Measurement<UnitSpeed> {
        switch self {
        case .plane:
                .init(value: 900, unit: .kilometersPerHour)
        case .car:
                .init(value: 110, unit: .kilometersPerHour)
        case .truck:
                .init(value: 90, unit: .kilometersPerHour)
        case .speedboat:
                .init(value: 20, unit: .knots)
        case .sailboat:
                .init(value: 6, unit: .knots)
        case .bicycle:
                .init(value: 20, unit: .kilometersPerHour)
        }
    }
    
    var defaultUnit: UnitSpeed {
        switch self {
        case .plane:
                .kilometersPerHour
        case .car:
                .kilometersPerHour
        case .truck:
                .kilometersPerHour
        case .speedboat:
                .knots
        case .sailboat:
                .knots
        case .bicycle:
                .kilometersPerHour
        }
    }
    
    func step(unit: UnitSpeed) -> Double {
        switch unit {
        case .kilometersPerHour:
            1.0
        case .knots:
            0.539957
        case .milesPerHour:
            0.621371
        default:
            fatalError("Unsupported Unit")
        }
    }
    
    func speedRangeArray(unit: UnitSpeed) -> [Int] {
        var speedRangeArray: [Int] = []
        for i in speedRange(unit: unit) {
            speedRangeArray.append(i)
        }
        return speedRangeArray
    }
    
    func speedRange(unit: UnitSpeed) -> ClosedRange<Int> {
        switch self {
        case .plane:
            switch unit {
            case .kilometersPerHour:
                100...1000
            case .knots:
                100...600
            case .milesPerHour:
                100...600
            default:
                fatalError("Unsupported Unit")
            }
        case .car:
            switch unit {
            case .kilometersPerHour:
                10...300
            case .knots:
                10...200
            case .milesPerHour:
                10...200
            default:
                fatalError("Unsupported Unit")
            }
        case .truck:
            switch unit {
            case .kilometersPerHour:
                10...200
            case .knots:
                10...120
            case .milesPerHour:
                10...150
            default:
                fatalError("Unsupported Unit")
            }
        case .speedboat:
            switch unit {
            case .kilometersPerHour:
                2...200
            case .knots:
                2...100
            case .milesPerHour:
                2...100
            default:
                fatalError("Unsupported Unit")
            }
        case .sailboat:
            switch unit {
            case .kilometersPerHour:
                1...60
            case .knots:
                1...40
            case .milesPerHour:
                1...40
            default:
                fatalError("Unsupported Unit")
            }
        case .bicycle:
            switch unit {
            case .kilometersPerHour:
                5...70
            case .knots:
                5...40
            case .milesPerHour:
                5...40
            default:
                fatalError("Unsupported Unit")
            }
        }
    }
    
    var title: String {
        switch self {
        case .plane:
            NSLocalizedString("Airplane", comment: "")
        case .car:
            NSLocalizedString("Car", comment: "")
        case .truck:
            NSLocalizedString("Truck", comment: "")
        case .speedboat:
            NSLocalizedString("Speedboat", comment: "")
        case .sailboat:
            NSLocalizedString("Sailboat", comment: "")
        case .bicycle:
            NSLocalizedString("Bicycle", comment: "")
        }
    }
}

extension VehicleType: Identifiable {
    var id: Self {
        self
    }
}
