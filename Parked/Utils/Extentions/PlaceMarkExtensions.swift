//
//  PlaceMarkExtensions.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI
import MapKit
import Contacts

extension Formatter {
    static let mailingAddress: CNPostalAddressFormatter = {
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        return formatter
    }()
}

extension CLPlacemark {
    var mailingAddress: String? {
        postalAddress?.mailingAddress
    }
}

extension CNPostalAddress {
    var mailingAddress: String {
        Formatter.mailingAddress.string(from: self)
    }
}
