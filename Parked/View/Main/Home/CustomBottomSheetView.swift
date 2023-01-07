//
//  CustomBottomSheetView.swift
//  KeepInTouch
//
//  Created by Natanael Jop on 01/09/2022.
//

import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 25
    static let indicatorHeight: CGFloat = 4
    static let indicatorWidth: CGFloat = 30
    static let snapRatio: CGFloat = 0.32
    static let minHeightRatio: CGFloat = 0.50
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
            )
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(Constants.radius, corners: [.topLeft, .topRight])
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    if self.offset + self.translation <= minHeight  {
                        state = value.translation.height
                    }
                }.onEnded { value in
                    let snapDistance = self.maxHeight * Constants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
            .shadow(color: .gray.opacity(0.3), radius: 15, y: -10)
        }.edgesIgnoringSafeArea(.bottom)
    }
}
