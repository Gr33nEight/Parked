//
//  ListSpotCustomTextField.swift
//  Parked
//
//  Created by Natanael Jop on 26/09/2022.
//

import SwiftUI

enum TextFieldFocusState {
    case none, street, city, state, zipcode
}

struct ListSpotCustomTextField: View {
    @Binding var isChecking: Bool
    @Binding var text: String
    @Binding var currentType: TextFieldFocusState
    
    var type: TextFieldFocusState?
    let placeholder: String
    
    var body: some View {
        HStack{
            ZStack(alignment: .leading){
                if text.isEmpty {
                    Text(placeholder)
                }
                TextField("", text: $text, onEditingChanged: { isFocused in
                    if isFocused { currentType = type ?? .none } else { currentType = .none }
                })
                    .foregroundColor(Color(UIColor.label))
                    .keyboardType(placeholder == "" ? .decimalPad : .default)
            }.foregroundColor(Color(UIColor.systemGray))
                .font(.system(size: 15))
            Spacer()
        }.padding(15)
        .background(
            ZStack {
                Color(UIColor.systemGray4)
                if isChecking && text.isEmpty {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 3)
                        .fill(.red)
                }
            }
        )
            .cornerRadius(10)

    }
}
