//
//  PageViewController.swift
//  JustWeather
//
//  Created by Julia Gurbanova on 25.02.2024.
//

import UIKit
import SnapKit
import Combine

class PageViewController: UIPageViewController {
    private var cityService = CityService.shared
    private var orderedViewControllers: [WeatherViewController] = []
    
    private var cancellables: Set<AnyCancellable> = []
    private let citySelectionViewModel = CitySelectionViewModel()
    
    private var currentIndex: Int {
        guard let currentViewController = viewControllers?.first else {
            return 0
        }
        return orderedViewControllers.firstIndex(of: currentViewController as! WeatherViewController) ?? 0
    }
    
    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .background
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
    
    // MARK: - INIT
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("pageviewcontroller loaded")
        dataSource = self
        delegate = self
        
        configureBottomBar()
        
        updateOrderedViewControllers()
        
        citySelectionViewModel.$selectedCityIndex
            .sink { [weak self] index in
                guard let index else { return }
                self?.navigateToCity(at: index)
            }
            .store(in: &cancellables)
        
        cityService.$savedCities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateOrderedViewControllers()
            }
            .store(in: &cancellables)
    }
    
    private func updateOrderedViewControllers() {
        var updatedViewControllers: [WeatherViewController] = []
        
        let currentLocationViewController = WeatherViewController()
        updatedViewControllers.append(currentLocationViewController)
        
        updatedViewControllers += cityService.savedCities.map { WeatherViewController(city: $0) }
        orderedViewControllers = updatedViewControllers
        
        pageControl.numberOfPages = orderedViewControllers.count
        
        setViewControllers([orderedViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @objc private func cityListButtonTapped() {
        let citySearchViewController = CitySearchViewController()
        citySearchViewController.citySelectionViewModel = citySelectionViewModel
        let navigationController = UINavigationController(rootViewController: citySearchViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    func navigateToCity(at index: Int) {
        guard index >= 0 && index < orderedViewControllers.count else {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection
        if index > currentIndex {
            direction = .forward
        } else if index < currentIndex {
            direction = .reverse
        } else {
            // If the index is the same, do not perform any navigation
            return
        }
        
        let selectedViewController = orderedViewControllers[index]
        
        setViewControllers([selectedViewController], direction: direction, animated: true, completion: nil)
        pageControl.currentPage = index
    }
    
    // MARK: - UI Setup
    private func configureBottomBar() {
        view.addSubview(bottomBar)
        
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        
        bottomBar.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(bottomBar)
            make.bottom.equalTo(bottomBar).inset(Offsets.standard)
        }
        
        bottomBar.addSubview(cityListButton)
        
        cityListButton.snp.makeConstraints { make in
            make.trailing.equalTo(bottomBar).inset(Offsets.standard)
            make.bottom.equalTo(bottomBar).inset(Offsets.standard)
            make.width.height.equalTo(IconSizes.button)
        }
    }
}

// MARK: - Extension

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
