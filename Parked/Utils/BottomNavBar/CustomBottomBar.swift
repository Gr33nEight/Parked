//
//  CustomBottomBar.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI

struct CustomBottomBar: View {
    @EnvironmentObject var bottomBarVM: BottomBarViewModel
    @Namespace var anim
    var body: some View {
        ZStack(alignment: .top){
            Color(UIColor.systemGray6)
            HStack{
                ForEach(BottomBarOptions.allCases, id:\.self){ option in
                    Spacer()
                    VStack(spacing: 2){
                        Button {
                            bottomBarVM.pickedOption = option
                        } label: {
                            Image(systemName: option.image)
                                .font(.system(size: 20))
                                .foregroundColor(bottomBarVM.pickedOption == option ? .green : Color(UIColor.systemGray))
                        }.padding(.top, 6)
                    }
                    Spacer()
                }
                
            }
        }
        .padding(.top, 7)
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxHeight: UIScreen.main.bounds.width/8)
        
    }
}
