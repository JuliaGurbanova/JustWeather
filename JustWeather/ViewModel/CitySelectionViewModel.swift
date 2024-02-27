//
//  CitySelectionViewModel.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 27.02.2024.
//

import Foundation
import Combine

class CitySelectionViewModel {
    @Published var selectedCityIndex: Int?

    func selectCity(at index: Int) {
        selectedCityIndex = index
    }
}
