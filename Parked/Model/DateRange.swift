//
//  DateRange.swift
//  Parked
//
//  Created by Natanael Jop on 28/09/2022.
//

import SwiftUI

struct DateRange: Hashable {
    var startDate: Date
    var endDate: Date
    var startDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/mm/y"
        formatter.dateStyle = .short
        return formatter.string(from: startDate)
    }
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    var endDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/mm/y"
        formatter.dateStyle = .short
        return formatter.string(from: endDate)
    }
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeStyle = .short
        return formatter.string(from: endDate)
    }
}

