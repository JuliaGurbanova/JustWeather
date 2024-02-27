//
//  Forecast.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import Foundation

struct Forecast: Decodable {
    let list: [Weather]
}

struct DailyForecast {
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let commonIcon: String
}
