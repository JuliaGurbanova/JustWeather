//
//  CitySearchViewController.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 25.02.2024.
//

import UIKit
import Combine
import SnapKit

protocol CitySearchDelegate: AnyObject {
    func didAddCity(_ city: String)
    func didSelectCity(at index: Int)
}

class CitySearchViewController: UIViewController {
    weak var delegate: CitySearchDelegate?
    private var cancellables: Set<AnyCancellable> = []

    private let viewModel = WeatherViewModel()
    let cityService = CityService.shared

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .blue

        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(20)
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func bindViewModel() {
        searchBar.delegate = self

        viewModel.$currentWeather
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension CitySearchViewController: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            viewModel.loadWeather(for: searchText)
            presentWeatherViewController(city: searchText)
        }
    }

    func presentWeatherViewController(city: String) {
        print("Presenting WeatherViewController with city: \(city)")
        let weatherViewController = WeatherViewController(city: city, isPresentedModally: true)
        weatherViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: weatherViewController)
        present(navigationController, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows is the count of saved cities plus the current location
        return cityService.savedCities.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.row == 0 {
            cell.textLabel?.text = "Current Location: \(viewModel.weatherService.cityName ?? "") - \(viewModel.currentWeather?.temperature.formatted ?? "")°C"
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
        delegate?.didSelectCity(at: selectedIndex)
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else {
            // Don't allow deletion for the "Current Location" row
            return
        }

        if editingStyle == .delete {
            let deletedCity = cityService.savedCities[indexPath.row - 1]
            cityService.removeCity(deletedCity)

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension CitySearchViewController: CitySearchDelegate {
    func didAddCity(_ city: String) {
        tableView.reloadData()
    }

    func didSelectCity(at index: Int) {

    }
}

