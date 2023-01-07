//
//  DatePickerExtension.swift
//  Parked
//
//  Created by Natanael Jop on 22/09/2022.
//


import SwiftUI

struct NoHitTesting: ViewModifier {
    func body(content: Content) -> some View {
        SwiftUIWrapper { content }.allowsHitTesting(false)
    }
}

extension View {
    func userInteractionDisabled() -> some View {
        self.modifier(NoHitTesting())
    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

extension TimeInterval{

        func doubleFromTimeInterval() -> Double {

            let time = CGFloat(self)
            let hours = (time / 3600)

            return hours

        }
    func stringFromTimeInterval() -> String {

                let time = NSInteger(self)

                let seconds = time % 60
                let minutes = (time / 60) % 60
                let hours = (time / 3600)

                return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)

            }
}
