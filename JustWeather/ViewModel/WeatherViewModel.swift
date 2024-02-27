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
    
    @Published var minMaxTemperatures: [String: (min: Double, max: Double)] = [:]
    @Published var iconsByDay: [String: String] = [:]
    @Published var dailyForecasts: [DailyForecast] = []
    
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] forecast in
                self?.forecast = forecast
                self?.calculateMinMaxTemperatures()
                self?.getMostCommonIconByDay()
                self?.generateDailyForecasts()
            }
            .store(in: &cancellables)
    }
    
    private func generateDailyForecasts() {
        dailyForecasts = []
        
        let groupedForecast = Dictionary(grouping: forecast) { weather in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: weather.time)
            return Calendar.current.date(from: components)
        }
        
        for (_, temperatures) in groupedForecast {
            let minTemperature = temperatures.map { $0.temperature }.min() ?? 0
            let maxTemperature = temperatures.map { $0.temperature }.max() ?? 0
            
            let mostCommonIcon = temperatures
                .map { $0.icon }
                .reduce(into: [:]) { counts, icon in counts[icon, default: 0] += 1 }
                .max { $0.value < $1.value }?.key ?? ""
            
            if let date = temperatures.first?.time {
                let dailyForecast = DailyForecast(date: date, minTemperature: minTemperature, maxTemperature: maxTemperature, commonIcon: mostCommonIcon)
                dailyForecasts.append(dailyForecast)
            }
        }
        
        dailyForecasts.sort { $0.date < $1.date }
    }
    
    private func calculateMinMaxTemperatures() {
        minMaxTemperatures = [:]
        
        let groupedTemperatures = Dictionary(grouping: forecast) { weather in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: weather.time)
        }
        
        for (day, temperatures) in groupedTemperatures {
            let minTemperature = temperatures.map { $0.temperature }.min() ?? 0
            let maxTemperature = temperatures.map { $0.temperature }.max() ?? 0
            minMaxTemperatures[day] = (min: minTemperature, max: maxTemperature)
        }
    }
    
    private func getMostCommonIconByDay() {
        var commonIconsByDay: [String: String] = [:]
        
        let groupedIcons = Dictionary(grouping: forecast) { weather in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: weather.time)
        }
        
        for (day, icons) in groupedIcons {
            let mostCommonIcon = icons
                .map { $0.icon }
                .reduce(into: [:]) { counts, icon in counts[icon, default: 0] += 1 }
                .max { $0.value < $1.value }?.key
            
            commonIconsByDay[day] = mostCommonIcon
        }
        iconsByDay = commonIconsByDay
    }
    
    func getDayKey(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
