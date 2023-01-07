//
//  User.swift
//  Parked
//
//  Created by Natanael Jop on 22/09/2022.
//

import SwiftUI
import CoreLocation

struct User: Identifiable, Hashable {
    var id = UUID()
    var fullname: String
    var email: String
    var phoneNumber: String
    var userSpots: [Spot]?
    var frameRange: DateRange?
    var uid: String?
    var reservationHistory: [String]?
    var bookingHistory: [String]?
    var car: Car
}
