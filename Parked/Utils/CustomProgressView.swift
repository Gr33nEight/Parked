//
//  CustomProgressView.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI

struct CustomProgressView: View {
    @State var isLoading = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)
                .frame(width: 100, height: 100)
 
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color("CustomGreen"), lineWidth: 7)
                .frame(width: 100, height: 100)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear() {
                    self.isLoading = true
            }
        }
    }
}

struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CustomProgressView()
    }
}
