//
//  ParkedApp.swift
//  Parked
//
//  Created by Natanael Jop on 20/09/2022.
//

import SwiftUI
import Firebase

@main
struct ParkedApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
