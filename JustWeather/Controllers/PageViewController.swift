//
//  PageViewController.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 25.02.2024.
//

import UIKit
import SnapKit

class PageViewController: UIPageViewController {
    private var cityService = CityService.shared
    private var orderedViewControllers: [WeatherViewController] = []

    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        return view
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private lazy var cityListButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(cityListButtonTapped), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        // Add current location weather view controller at the beginning
        let currentLocationViewController = WeatherViewController()
        orderedViewControllers.append(currentLocationViewController)

        // Add saved cities weather view controllers
        orderedViewControllers += cityService.savedCities.map { WeatherViewController(city: $0) }

        if let initialViewController = orderedViewControllers.first {
            setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        }

        configureBottomBar()
    }

    private func configureBottomBar() {
        view.addSubview(bottomBar)

        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80) // You can adjust the height based on your preference
        }

        bottomBar.addSubview(pageControl)

        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(bottomBar)
            make.bottom.equalTo(bottomBar).inset(20)
        }

        bottomBar.addSubview(cityListButton)

        cityListButton.snp.makeConstraints { make in
            make.trailing.equalTo(bottomBar).inset(20)
            make.bottom.equalTo(bottomBar).inset(20)
            make.width.height.equalTo(40)
        }
    }

    // MARK: - Actions
    @objc private func cityListButtonTapped() {
        let citySearchViewController = CitySearchViewController()
        citySearchViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: citySearchViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController as! WeatherViewController), viewControllerIndex > 0 else {
            return nil
        }

        return orderedViewControllers[viewControllerIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController as! WeatherViewController), viewControllerIndex < orderedViewControllers.count - 1 else {
            return nil
        }

        return orderedViewControllers[viewControllerIndex + 1]
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: currentViewController as! WeatherViewController) {
            pageControl.currentPage = index
        }
    }
}

extension PageViewController: CitySearchDelegate {
    func didAddCity(_ city: String) {
    }
    
    func didSelectCity(at index: Int) {
        guard index >= 0, index < orderedViewControllers.count else {
            return
        }

        setViewControllers([orderedViewControllers[index]], direction: .forward, animated: true, completion: nil)
        pageControl.currentPage = index
    }
}
