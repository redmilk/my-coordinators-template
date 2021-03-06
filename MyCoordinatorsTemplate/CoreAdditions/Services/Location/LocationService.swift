//
//  LocationService.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import CoreLocation
import RxSwift
import RxCocoa

enum LocationAccuracy {
    case bestForNavigation
    case best
    case nearestTenMeters
    case hundredMeters
    case kilometer
    case threeKilometers
}

protocol LocationServiceProtocol {
    var locationServicesAuthorizationStatus: BehaviorSubject<CLAuthorizationStatus?> { get }
    var currentLocation: Observable<CLLocation> { get }
    
    func requestPermission()
    func setAccuracy(_ accuracy: LocationAccuracy)
}

final class LocationService: NSObject, LocationServiceProtocol {
    
    var currentLocation: Observable<CLLocation> {
        return locationManager.rx.didUpdateLocations
            .map { locations in locations[0] }
            .filter { [unowned self] location in
                return location.horizontalAccuracy < self.accuracy
            }
            .throttle(.seconds(30), latest: true, scheduler: MainScheduler.asyncInstance)
    }
    
    var locationServicesAuthorizationStatus = BehaviorSubject<CLAuthorizationStatus?>(value: nil)
    
    func setAccuracy(_ accuracy: LocationAccuracy) {
        switch accuracy {
        case .bestForNavigation:
            self.accuracy = kCLLocationAccuracyBestForNavigation
        case .best:
            self.accuracy = kCLLocationAccuracyBest
        case .nearestTenMeters:
            self.accuracy = kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            self.accuracy = kCLLocationAccuracyHundredMeters
        case .kilometer:
            self.accuracy = kCLLocationAccuracyKilometer
        case .threeKilometers:
            self.accuracy = kCLLocationAccuracyThreeKilometers
        }
    }
    
    func requestPermission() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func isEnabled() -> Bool {
        guard let status = try? locationServicesAuthorizationStatus.value() else {
            return false
        }
        return CLLocationManager.locationServicesEnabled() && (status == .authorizedWhenInUse || status == .authorizedAlways)
    }
    
    init(accuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters) {
        self.accuracy = accuracy
        self.locationManager.rx
            .didChangeAuthorizationStatus
            .bind(to: locationServicesAuthorizationStatus)
            .disposed(by: bag)
        super.init()
    }
    
    private let locationManager = CLLocationManager()
    private var accuracy: CLLocationAccuracy
    private let bag = DisposeBag() 
}
