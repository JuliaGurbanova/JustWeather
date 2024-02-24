//
//  Double+Extension.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import Foundation

extension Double {
    var formatted: String {
        String(format: "%.0f", self)
    }
}
