//
//  TestView.swift
//  Parked
//
//  Created by Natanael Jop on 19/10/2022.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("reservation.spot.address")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal, 5)
                Spacer()
                Text("$\("reservation.spot.price.rounded()")")
                    .foregroundColor(Color.revLabel)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(5)
            }
            Text("\("reservation.frameRange.startTimeString") - \("reservation.frameRange.endTimeString")")
                .padding(.horizontal, 5)
                .padding(.top)
            Rectangle()
                .frame(height: 1.5)
            HStack {
                VStack(alignment: .leading){
                    Text("reservation.renter?.fullname" ?? "error")
                    Text("\("reservation.renter?.car.model" ?? "") \("reservation.renter?.car.make" ?? "") \("reservation.renter?.car.color" ?? "")")
                    Text("reservation.renter?.phoneNumber" ?? "error")
                }.padding(.horizontal, 5)
                Spacer()
                Button {
//                    ChatView()
                } label: {
                    Text("Report")
                        .foregroundColor(Color(UIColor.label))
                        .font(.system(size: 17, weight: .semibold))
                        .padding(5)
                        .padding(.horizontal, 10)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.revLabel))
                }
            }
            
        }.foregroundColor(.white)
        .padding(20)
            .background(RoundedRectangle(cornerRadius: 10))

    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
