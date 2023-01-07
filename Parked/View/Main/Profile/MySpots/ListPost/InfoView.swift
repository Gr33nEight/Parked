//
//  InfoView.swift
//  Parked
//
//  Created by Natanael Jop on 11/10/2022.
//

import SwiftUI

struct InfoView: View {
    @Binding var showInfo: Bool
    let text: String
    var body: some View {
        ZStack{
//            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20){
                Text(text)
                    .multilineTextAlignment(.center)

            }.padding(30)
                .overlay(
                    Button(action: {
                        showInfo = false
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(Color(UIColor.label))
                            .padding(20)
                    })
                    , alignment: .topLeading
                )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.revLabel)
                    .shadow(radius: 4)
            ).padding(30)
                .padding(.bottom, 70)
                
        }
    }
}
