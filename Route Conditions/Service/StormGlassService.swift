//
//  StormGlassService.swift
//  Route Conditions
//
//  Created by Tassilo Bouwman on 23.06.23.
//

import Foundation
import StormGlass
import Get
import OSLog
import CoreLocation

class StormGlassService {
    private var client: APIClient
    private let url = URL(string: "https://api.stormglass.io/v2")
    private let logger = OSLog.network
    
    static let shared = StormGlassService()
    
    private init() {
        let configuration = APIClient.Configuration(baseURL: url, delegate: ClientDelegate())
        configuration.sessionConfiguration.timeoutIntervalForRequest = Constants.Network.timeout
        
        let client = APIClient(configuration: configuration)
        
        self.client = client
    }
    
    /// Example for fetching the wave height.
    /// You can fetch multiple weather parameters by spcifying them in the 'params', eg. "waveHeight,waveDirection,windSpeed'
    func waveAndCurrentForecast(for coordinate: CLLocationCoordinate2D) async throws -> [WeatherModelConvertible] {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let parameters = Paths.Point.GetParameters(lat: latitude, lng: longitude, params: "currentSpeed,currentDirection,waveDirection,waveHeight", source: "sg")
        let request = Paths.point.get(parameters: parameters)
        let response = try await client.send(request)
        
        guard let data = response.value.data else { throw RouteError.Network.missingData }
        return data
    }
}


final class ClientDelegate: APIClientDelegate {
    private var accessToken: String = "cf682b30-078e-11ee-a26f-0242ac130002-cf682bda-078e-11ee-a26f-0242ac130002"
    
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) async throws {
        request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    func client(_ client: APIClient, validateResponse response: HTTPURLResponse, data: Data, task: URLSessionTask) throws {
        // print("\(String(data: data, encoding: .utf8) ?? "response data encoding failed")")
    }
}
