//
//  WeatherViewController.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import UIKit
import Combine
import SnapKit

class WeatherViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []

    private let weatherService = WeatherService()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let cityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    private let currentWeatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let forecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        weatherService.requestLocation()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0) // Light blue background color

        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(locationLabel.snp.bottom).offset(5)
        }

        view.addSubview(cityLabel)
        cityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(5)
        }

        view.addSubview(currentTemperatureLabel)
        currentTemperatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cityLabel.snp.bottom).offset(20)
        }

        view.addSubview(currentWeatherIcon)
        currentWeatherIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currentTemperatureLabel.snp.bottom).offset(20)
            make.width.height.equalTo(80)
        }

        view.addSubview(forecastTableView)
        forecastTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(currentWeatherIcon.snp.bottom).offset(20)
        }

        forecastTableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: ForecastTableViewCell.reuseIdentifier)
        forecastTableView.dataSource = self
    }


    private func bindViewModel() {
        weatherService.$current
            .sink { [weak self] weather in
                self?.updateCurrentWeatherUI(weather)
            }
            .store(in: &cancellables)

        weatherService.$forecast
            .sink { [weak self] _ in
                self?.forecastTableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func updateCurrentWeatherUI(_ weather: Weather?) {
        guard let weather = weather else { return }

        locationLabel.text = "Current Location" // Replace with actual location
        dateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        currentTemperatureLabel.text = "\(weather.temperature.formatted)°C"
        currentWeatherIcon.image = UIImage(systemName: weather.icon.weatherIcon)

        if let cityName = weatherService.cityName {
            cityLabel.text = cityName
        }
    }
}

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherService.forecast.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCell.reuseIdentifier, for: indexPath) as! ForecastTableViewCell
        cell.configure(with: weatherService.forecast[indexPath.row])
        return cell
    }
}
