//
//  Vehicle+Extension.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 22.06.23.
//

import Foundation

private let formatter = MeasurementFormatter()

extension UnitSpeed {
    static var all: [UnitSpeed] {
        [.kilometersPerHour, .milesPerHour, .knots]
    }
    
    var title: String {
        formatter.string(from: self)
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

extension VehicleType {
    static var all: [VehicleType] {
        [.car, .truck, .speedboat, .sailboat, .bicycle]
    }
    
    var imageName: String {
        switch self {
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
    
    var defaultUnit: UnitSpeed {
        switch self {
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
    
    func speedRange(unit: UnitSpeed) -> ClosedRange<Measurement<UnitSpeed>> {
        switch self {
        case .car:
            switch unit {
            case .kilometersPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 300, unit: .kilometersPerHour))
            case .knots:
                    .init(value: 1, unit: .knots)...(.init(value: 200, unit: .kilometersPerHour))
            case .milesPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 200, unit: .kilometersPerHour))
            default:
                fatalError("Unsupported Unit")
            }
        case .truck:
            switch unit {
            case .kilometersPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 200, unit: .kilometersPerHour))
            case .knots:
                    .init(value: 1, unit: .knots)...(.init(value: 150, unit: .kilometersPerHour))
            case .milesPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 150, unit: .kilometersPerHour))
            default:
                fatalError("Unsupported Unit")
            }
        case .speedboat:
            switch unit {
            case .kilometersPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 200, unit: .kilometersPerHour))
            case .knots:
                    .init(value: 1, unit: .knots)...(.init(value: 150, unit: .kilometersPerHour))
            case .milesPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 150, unit: .kilometersPerHour))
            default:
                fatalError("Unsupported Unit")
            }
        case .sailboat:
            switch unit {
            case .kilometersPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 100, unit: .kilometersPerHour))
            case .knots:
                    .init(value: 1, unit: .knots)...(.init(value: 60, unit: .kilometersPerHour))
            case .milesPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 70, unit: .kilometersPerHour))
            default:
                fatalError("Unsupported Unit")
            }
        case .bicycle:
            switch unit {
            case .kilometersPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 70, unit: .kilometersPerHour))
            case .knots:
                    .init(value: 1, unit: .knots)...(.init(value: 40, unit: .kilometersPerHour))
            case .milesPerHour:
                    .init(value: 1, unit: .kilometersPerHour)...(.init(value: 50, unit: .kilometersPerHour))
            default:
                fatalError("Unsupported Unit")
            }
        }
    }
    
    var title: String {
        switch self {
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
