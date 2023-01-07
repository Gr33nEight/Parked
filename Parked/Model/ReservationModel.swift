//
//  ReservationModel.swift
//  Parked
//
//  Created by Natanael Jop on 04/10/2022.
//

import SwiftUI

struct Reservation: Identifiable, Hashable {
    var id = UUID()
    var spot: Spot
    var frameRange: DateRange
    var name: String
    var bookingUserID: String
    var spotID: String
    var reservationID: String?
    var owner: User?
    var renter: User?
}
