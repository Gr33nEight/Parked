//
//  Car.swift
//  Parked
//
//  Created by Natanael Jop on 05/10/2022.
//

import SwiftUI

struct Car: Identifiable, Hashable {
    var id = UUID()
    var make: String
    var model: String
    var color: String
}
