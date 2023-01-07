//
//  LocationService.swift
//  Parked
//
//  Created by Natanael Jop on 20/09/2022.
//

import Foundation
import Combine
import MapKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    enum LocationStatus: Equatable {
        case idle
        case noResults
        case isSearching
        case error(String)
        case result
    }
    
    @Published var queryFragment: String = ""
    @Published var city = ""
    @Published var street = ""
    @Published var state = ""
    @Published private(set) var status: LocationStatus = .idle
    @Published private(set) var searchResults: [MKLocalSearchCompletion] = []
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    
    private var locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    
    private var queryCancellable: AnyCancellable?
    private let searchCompleter: MKLocalSearchCompleter!
    
    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.searchCompleter = searchCompleter
        super.init()
        self.searchCompleter.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        queryCancellable = $queryFragment
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
            .sink(receiveValue: { fragment in
                self.status = .isSearching
                if !fragment.isEmpty {
                    self.searchCompleter.queryFragment = fragment
                } else {
                    self.status = .idle
                    self.searchResults = []
                }
            })
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
    }
}

extension LocationService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
        completer.region = MKCoordinateRegion(.world)
        completer.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        self.searchResults = completer.results
        self.status = completer.results.isEmpty ? .noResults : .result
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
}
