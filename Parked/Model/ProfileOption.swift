//
//  ProfileOptions.swift
//  Parked
//
//  Created by Natanael Jop on 20/09/2022.
//

import SwiftUI

struct ProfileOption: Identifiable {
    var id = UUID()
    var name: String
    var destination: AnyView
}
