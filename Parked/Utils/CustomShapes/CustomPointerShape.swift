//
//  CustomPointerShape.swift
//  Parked
//
//  Created by Natanael Jop on 24/09/2022.
//

import SwiftUI


struct CustomPointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX/1.15, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY), control: CGPoint(x: rect.minX+15, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct CustomPointerShape_Previews: PreviewProvider {
    static var previews: some View {
        CustomPointer(amount: 13.000, isAvailable: true)
//            .scaleEffect(0.4)
    }
}


struct CustomPointer: View {
    let amount: Double
    let isAvailable: Bool
    var body: some View {
            ZStack{
                Image(isAvailable ? "availablePin" : "takenPin")
                Text("$\(amount, specifier: "%.f")")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: -38)
            }
    }
}


