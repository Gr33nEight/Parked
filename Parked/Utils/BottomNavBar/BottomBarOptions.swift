//
//  BottomBarOptions.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//


import SwiftUI

enum BottomBarOptions: CaseIterable {
    case home, reservations, profile
    
    var image: String {
        switch self {
        case .home:
            return "house"
        case .reservations:
            return "globe"
        case .profile:
            return "person"
        }
    }
    
    var view: AnyView {
        switch self {
        case .home:
            return AnyView(HomeMainView())
        case .reservations:
            return AnyView(ReserveMainView())
        case .profile:
            return AnyView(ProfileMainView())
        }
        
    }
}
