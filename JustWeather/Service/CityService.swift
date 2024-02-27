//
//  CityService.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 25.02.2024.
//

import Foundation
import Combine

class CityService {
    static let shared = CityService()
    
    @Published var savedCities: [String] {
        didSet {
            saveCitiesToUserDefaults()
            print("Saved cities updated: \(savedCities)")
        }
    }
    
    private init() {
        savedCities = UserDefaults.standard.stringArray(forKey: "SavedCities") ?? []
    }
    
    private func saveCitiesToUserDefaults() {
        UserDefaults.standard.set(savedCities, forKey: "SavedCities")
    }
    
    func addCity(_ city: String) {
        guard !savedCities.contains(city) else {
            return
        }
        
        savedCities.append(city)
    }
    
    func removeCity(_ city: String) {
        savedCities.removeAll { $0 == city }
    }
}
