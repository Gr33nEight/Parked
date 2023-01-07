//
//  ListSpotNextButton.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI

struct ListSpotNextButton: View {
    let function: () -> Void
    let isLast: Bool
    var body: some View {
        HStack{
            Spacer()
            Button {
                function()
            } label: {
                Text(isLast ? "Confirm" : "Next")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.vertical, 15)
                    .padding(.horizontal, 100)
                    .background {
                        Color("CustomGreen")
                            .cornerRadius(10)
                            .shadow(radius: 2, y: 3)
                    }
            }
            Spacer()
        }
    }
}
