//
//  Spot.swift
//  Parked
//
//  Created by Natanael Jop on 28/09/2022.
//

import SwiftUI
import MapKit

struct Spot: Identifiable, Hashable {
    var id = UUID()
    var image: String
    var licenseImage: String
    var location: Location
    var address: String {
        return "\(location.street), \(location.city), \(location.zip_code)"
    }
    var convertedLocation: CLLocation
    var availabilityRange: [AvailabilityRange]
    var price: Double
    var notes: String
    var isAvailable: Bool
    var ownerID: String
    var sid: String
    var timeDifference: Int?
    var isApproved: Bool
    var isHidden: Bool
}
