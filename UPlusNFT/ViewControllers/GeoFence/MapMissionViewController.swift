//
//  MapMissionViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/09/08.
//

import UIKit
import MapKit

final class MapMissionViewController: UIViewController {
    
    lazy var locationManager = CLLocationManager()
    
    private let map: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()

        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let `self` = self else { return }
            
            print("User Location: \(self.map.userLocation.location)")
            self.map.zoomToLocation(self.map.userLocation.location)
            self.addRadiusOverlay(forGeotification: self.map.userLocation.coordinate, radius: 900)
            
            self.startMonitoring(region: CLCircularRegion(center: self.map.userLocation.coordinate,
                                                          radius: 900,
                                                          identifier: "myGeotification"))
        }
        
        
    }
    
}

extension MapMissionViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      // 1
      let status = manager.authorizationStatus

      // 2
        map.showsUserLocation = (status == .authorizedAlways)

      // 3
      if status != .authorizedAlways {
        let message = """
        Your geotification is saved but will only be activated once you grant
        Geotify permission to access the device location.
        """
        print("\(message)")
      }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User did enter the region: \(region)")
    }

    func locationManager(
      _ manager: CLLocationManager,
      monitoringDidFailFor region: CLRegion?,
      withError error: Error
    ) {
      guard let region = region else {
        print("Monitoring failed for unknown region")
        return
      }
      print("Monitoring failed for region with identifier: \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location Manager failed with the following error: \(error)")
    }
    
}

extension MapMissionViewController {
    private func setUI() {
        self.view.addSubviews(self.map)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.map.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.map.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.map.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            self.map.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}


extension MapMissionViewController {
    func startMonitoring(region: CLCircularRegion) {
      // 1
      if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
          UPlusLogger.logger.error("Geofencing is not supported on this device!")
      }

      locationManager.startMonitoring(for: region)
    }
    
    func addRadiusOverlay(forGeotification coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = MKCircle(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: radius)
        self.map.addOverlay(circle)
    }
}

extension MKMapView {
    func zoomToLocation(_ location: CLLocation?) {
        guard let coordinate = location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        setRegion(region, animated: true)
    }
}
