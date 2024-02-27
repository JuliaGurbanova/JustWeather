//
//  ForecastTableViewCell.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 24.02.2024.
//

import UIKit
import SnapKit

class ForecastTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ForecastTableViewCell"

    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private let minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private let maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private let weatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(dateTimeLabel)
        dateTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(maxTemperatureLabel)
        maxTemperatureLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(minTemperatureLabel)
        minTemperatureLabel.snp.makeConstraints { make in
            make.trailing.equalTo(maxTemperatureLabel.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(weatherIcon)
        weatherIcon.snp.makeConstraints { make in
            make.trailing.equalTo(minTemperatureLabel.snp.leading).offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }

    func configure(with dailyForecast: DailyForecast) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateTimeLabel.text = dateFormatter.string(from: dailyForecast.date)

        minTemperatureLabel.text = "\(dailyForecast.minTemperature.formatted)°C"
        maxTemperatureLabel.text = "\(dailyForecast.maxTemperature.formatted)°C"
        weatherIcon.image = UIImage(systemName: dailyForecast.commonIcon.weatherIcon)
    }
}
