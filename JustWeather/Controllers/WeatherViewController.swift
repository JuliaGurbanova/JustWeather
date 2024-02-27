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
    var cityName: String?
    private let viewModel = WeatherViewModel()
    private let cityService = CityService.shared
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: FontSizes.title, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: FontSizes.standard)
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: FontSizes.standard)
        return label
    }()
    
    private let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: FontSizes.large, weight: .bold)
        return label
    }()
    
    private let currentWeatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemIndigo
        return imageView
    }()
    
    private let weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: FontSizes.standard, weight: .semibold)
        return label
    }()
    
    private let forecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    var isPresentedModally = false
    
    
    // MARK: - INIT
    init(city: String, isPresentedModally: Bool = false) {
        self.isPresentedModally = isPresentedModally
        self.cityName = city
        super.init(nibName: nil, bundle: nil)
    }
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        if let cityName = cityName {
            loadData(for: cityName)
            locationLabel.text = cityName
        } else {
            loadData()
        }
        
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            navigationItem.leftBarButtonItem?.tintColor = .white
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItem?.tintColor = .white
            
        }
    }
    
    // MARK: - Data handling
    
    private func bindViewModel() {
        viewModel.$currentWeather
            .sink { [weak self] weather in
                self?.updateCurrentWeatherUI(weather)
            }
            .store(in: &cancellables)
        
        viewModel.$forecast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.forecastTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func loadData(for city: String? = nil) {
        if let city = city {
            viewModel.loadWeather(for: city)
        } else {
            viewModel.loadWeather()
        }
    }
    
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        if let cityName {
            cityService.addCity(cityName)
        }
        dismiss(animated: true)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .background)
        
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Offsets.standard)
        }
        
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(locationLabel.snp.bottom).offset(Offsets.small)
        }
        
        view.addSubview(cityLabel)
        cityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(Offsets.small)
        }
        
        view.addSubview(currentTemperatureLabel)
        currentTemperatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cityLabel.snp.bottom).offset(Offsets.standard)
        }
        
        view.addSubview(currentWeatherIcon)
        currentWeatherIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currentTemperatureLabel.snp.bottom).offset(Offsets.standard)
            make.width.height.equalTo(IconSizes.big)
        }
        
        view.addSubview(weatherDescriptionLabel)
        weatherDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currentWeatherIcon.snp.bottom).offset(Offsets.standard)
        }
        
        view.addSubview(forecastTableView)
        forecastTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Offsets.standard)
            make.bottom.equalToSuperview().inset(Offsets.large)
            make.top.equalTo(weatherDescriptionLabel.snp.bottom).offset(Offsets.standard)
        }
        
        forecastTableView.backgroundColor = .white.withAlphaComponent(0.2)
        forecastTableView.layer.cornerRadius = 10
        forecastTableView.layer.masksToBounds = true
        
        forecastTableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: ForecastTableViewCell.reuseIdentifier)
        forecastTableView.dataSource = self
    }
    
    private func updateCurrentWeatherUI(_ weather: Weather?) {
        guard let weather = weather else {
            return }
        
        locationLabel.text = cityName ?? "Current Location"
        dateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        currentTemperatureLabel.text = "\(weather.temperature.formatted)°C"
        currentWeatherIcon.image = UIImage(systemName: weather.icon.weatherIcon)
        weatherDescriptionLabel.text = weather.summary
        
        cityLabel.text = cityName != nil ? nil : viewModel.weatherService.cityName
        
    }
}

// MARK: - data source
extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dailyForecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCell.reuseIdentifier, for: indexPath) as! ForecastTableViewCell
        let dailyForecast = viewModel.dailyForecasts[indexPath.row]
        cell.configure(with: dailyForecast)
        return cell
    }
}
