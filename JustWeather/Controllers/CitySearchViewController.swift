//
//  CitySearchViewController.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 25.02.2024.
//

import UIKit
import Combine
import SnapKit

class CitySearchViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    var citySelectionViewModel: CitySelectionViewModel?
    
    private let viewModel = WeatherViewModel()
    let cityService = CityService.shared
    var didSelectCity: ((Int) -> Void)?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .background
        searchBar.barTintColor = .background
        searchBar.placeholder = "Search for a city"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .background
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        observeCityServiceChanges()
    }
    
    // MARK: - Data handling
    private func bindViewModel() {
        searchBar.delegate = self
        viewModel.$currentWeather
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func observeCityServiceChanges() {
        CityService.shared.$savedCities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Offsets.standard)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(Offsets.standard)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - Delegate Extension

extension CitySearchViewController: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchBar.resignFirstResponder()
            viewModel.loadWeather(for: searchText)
            presentWeatherViewController(city: searchText)
        }
        searchBar.text = nil
    }
    
    func presentWeatherViewController(city: String) {
        let weatherViewController = WeatherViewController(city: city, isPresentedModally: true)
        let navigationController = UINavigationController(rootViewController: weatherViewController)
        present(navigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityService.savedCities.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        if indexPath.row == 0 {
            cell.textLabel?.text = "Current Location"
        } else {
            if !cityService.savedCities.isEmpty {
                let savedCity = cityService.savedCities[indexPath.row - 1]
                cell.textLabel?.text = savedCity
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        citySelectionViewModel?.selectCity(at: selectedIndex)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Don't allow deletion for the "Current Location" row
        guard indexPath.row > 0 else {
            return
        }
        
        if editingStyle == .delete {
            let deletedCity = cityService.savedCities[indexPath.row - 1]
            cityService.removeCity(deletedCity)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
