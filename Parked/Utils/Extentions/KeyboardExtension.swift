//
//  KeyboardExtension.swift
//  Parked
//
//  Created by Natanael Jop on 28/09/2022.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
