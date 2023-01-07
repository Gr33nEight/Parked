//
//  AvailabilityRange.swift
//  Parked
//
//  Created by Natanael Jop on 05/10/2022.
//

import SwiftUI

struct AvailabilityRange: Identifiable, Hashable {
    var id = UUID()
    var day: String
    var startDate: Date
    var endDate: Date
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeStyle = .short
        return formatter.string(from: endDate)
    }
}
