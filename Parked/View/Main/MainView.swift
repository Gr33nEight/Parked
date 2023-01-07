//
//  ContentView.swift
//  Parked
//
//  Created by Natanael Jop on 20/09/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject var locationService = LocationService()
    @StateObject var userVM = UserViewModel()
    @StateObject var bottomBarVM = BottomBarViewModel()
    @StateObject var spotsVM = SpotsViewModel()
    @StateObject var reservationVM = ReservationsViewModel()
    var body: some View {
        Group {
            if userVM.isLoading {
                ZStack{
                    Color.revLabel.ignoresSafeArea()
                    CustomProgressView()
                }
            } else if userVM.isLoggedIn {
                ZStack(alignment: .trailing){
                    VStack(spacing: 0){
                        bottomBarVM.pickedOption.view
                        CustomBottomBar().edgesIgnoringSafeArea(.bottom)
                            .ignoresSafeArea(.keyboard)
                    }
                    if spotsVM.isLoading {
                        LoadingScreen()
                    }
                }
            }else{
                AuthView()
            }
           
        }
        .environmentObject(reservationVM)
            .environmentObject(userVM)
            .environmentObject(locationService)
            .environmentObject(bottomBarVM)
            .environmentObject(spotsVM)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
