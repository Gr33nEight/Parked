//
//  BottomBarViewModel.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI

class BottomBarViewModel: ObservableObject {
    @Published var pickedOption: BottomBarOptions = .home
}
