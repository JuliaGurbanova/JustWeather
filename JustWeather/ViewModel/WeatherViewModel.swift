//
//  WeatherViewModel.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var current: Weather?
    @Published var forecast: [Weather] = []
    
    private let weatherService: WeatherService
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
        
        weatherService.$current
            .assign(to: \.current, on: self)
            .store(in: &cancellables)
        
        weatherService.$forecast
            .assign(to: \.forecast, on: self)
            .store(in: &cancellables)
    }
    
    func requestLocation() {
        weatherService.requestLocation()
    }
}
