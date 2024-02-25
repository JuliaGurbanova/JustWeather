//
//  WeatherViewModel.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var currentWeather: Weather?
    @Published var forecast: [Weather] = []

    let weatherService = WeatherService()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        setupBindings()
    }

    func loadWeather(for city: String? = nil) {
        if let city {
            weatherService.loadForCity(city)
        } else {
            weatherService.requestLocation()
        }
    }

    func loadWeather(latitude: Float, longitude: Float) {
        weatherService.load(latitude: latitude, longitude: longitude)
    }

    private func setupBindings() {
        weatherService.$current
            .assign(to: \.currentWeather, on: self)
            .store(in: &cancellables)

        weatherService.$forecast
            .assign(to: \.forecast, on: self)
            .store(in: &cancellables)

    }
}
