//
//  WeatherService.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import Foundation
import Combine
import CoreLocation

class WeatherService: NSObject, ObservableObject {
    @Published var errorMessage: String = ""
    @Published var current: Weather?
    @Published var forecast: [Weather] = []
    @Published var cityName: String?

    private let apiKey = "5167337d06b1dd08f7575023f638cebb"
    private var cancellables: Set<AnyCancellable> = []
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func requestLocation() {
        guard let location = locationManager.location else {
            errorMessage = "Unable to fetch location."
            return
        }
        load(latitude: Float(location.coordinate.latitude), longitude: Float(location.coordinate.longitude))
        locationManager.stopUpdatingLocation()
    }
    
    func load(latitude: Float, longitude: Float) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let currentURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric")!
        URLSession.shared.dataTaskPublisher(for: URLRequest(url: currentURL))
            .map(\.data)
            .decode(type: Weather.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] currentWeather in
                self?.current = currentWeather
            }
            .store(in: &cancellables)
        
        let forecastURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric")!
        URLSession.shared.dataTaskPublisher(for: URLRequest(url: forecastURL))
            .map(\.data)
            .decode(type: Forecast.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] forecast in
                self?.forecast = forecast.list
            }
            .store(in: &cancellables)

        let geocoder = CLGeocoder()
                let location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))

                geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                    guard let self = self else { return }

                    if let error = error {
                        self.errorMessage = "Reverse geocoding error: \(error.localizedDescription)"
                        return
                    }

                    if let placemark = placemarks?.first {
                        self.cityName = placemark.locality
                    }
                }
    }
}

extension WeatherService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        load(latitude: Float(location.coordinate.latitude), longitude: Float(location.coordinate.longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
}