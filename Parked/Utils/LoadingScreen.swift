//
//  LoadingScreen.swift
//  Parked
//
//  Created by Natanael Jop on 29/09/2022.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            Color.revLabel.opacity(0.7).ignoresSafeArea()
            CustomProgressView()
        }
    }
}
