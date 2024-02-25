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
    func didSelectCity(_ city: String)
}

class CitySearchViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []

    private let weatherService = WeatherService()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a city"
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    weak var delegate: CitySearchDelegate?

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

        weatherService.$current
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension CitySearchViewController: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            weatherService.loadForCity(searchText)
            let weatherViewController = WeatherViewController(city: searchText)
            let navigationController = UINavigationController(rootViewController: weatherViewController)
            present(navigationController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.row == 0 {
            cell.textLabel?.text = "Current Location: \(weatherService.cityName ?? "") - \(weatherService.current?.temperature.formatted ?? "")°C"
        } else {
            let weather = weatherService.forecast[indexPath.row - 1]
            cell.textLabel?.text = "\(weatherService.cityName ?? "") - \(weather.temperature.formatted)°C"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0, let cityName = weatherService.cityName {
            delegate?.didSelectCity(cityName)
        }
        dismiss(animated: true, completion: nil)
    }
}
