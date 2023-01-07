//
//  ParkingHistoryView.swift
//  Parked
//
//  Created by Natanael Jop on 04/10/2022.
//

import SwiftUI

struct ParkingHistoryView: View {
    
    @EnvironmentObject var reservationVM: ReservationsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack{
            Rectangle()
                .frame(height: 2)
                .padding()
            if userVM.reservationHistory.isEmpty {
                VStack{
                    Spacer()
                    Text("You don't have any parking history")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 22, weight: .semibold))
                        .padding(30)
                    Spacer()
                }
            }else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20){
                        ForEach(Array(Set(userVM.reservationHistory))) { reservation in
                            ReservationCell(reservation: reservation, color: Color(UIColor.systemGray3))
                        }
                    }.padding(.horizontal)
                }
            }
            
        }.background(Color(UIColor.systemGray6))
        .navigationTitle("Parking History")
    }
}

struct ParkingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ParkingHistoryView().environmentObject(SpotsViewModel())
    }
}
