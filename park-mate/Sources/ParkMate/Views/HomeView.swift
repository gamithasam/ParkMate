// This is free software: you can redistribute and/or modify it
// under the terms of the GNU General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct CustomCorner: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                   radius: radius,
                   startAngle: .degrees(180),
                   endAngle: .degrees(270),
                   clockwise: false)
        
        // Top right corner
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                   radius: radius,
                   startAngle: .degrees(270),
                   endAngle: .degrees(0),
                   clockwise: false)
        
        // Bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Bottom left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.closeSubpath()
        return path
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Where Are You Planning to Park?")
                    .font(.title3)
                Spacer()
                Image("Logo")
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            .padding(.trailing, 33.5)
            .padding(.bottom, 16.25)
            MapView()
                .clipShape(CustomCorner(radius: 24))
        }
    }
}
