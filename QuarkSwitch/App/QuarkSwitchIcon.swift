import SwiftUI

/// Quarks identity extended for keyboard-layout switching.
/// Silver Q, two lavender directions, ample silhouette at Finder sizes.
struct QuarkSwitchIcon: View {
    var body: some View {
        GeometryReader { geometry in
            let s = geometry.size.width * 0.88
            let lavender = Color(red: 0.73, green: 0.61, blue: 0.96)
            ZStack {
                RoundedRectangle(cornerRadius: s * 0.215, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.15, green: 0.15, blue: 0.19), Color(red: 0.035, green: 0.035, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        RoundedRectangle(cornerRadius: s * 0.215, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.16), lineWidth: s * 0.004)
                    }
                Circle()
                    .trim(from: 0.04, to: 0.94)
                    .stroke(LinearGradient(colors: [.white, Color(red: 0.56, green: 0.56, blue: 0.64)], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: s * 0.052, lineCap: .round))
                    .rotationEffect(.degrees(45))
                    .frame(width: s * 0.65, height: s * 0.65)
                Path { path in
                    path.move(to: CGPoint(x: s * 0.63, y: s * 0.65))
                    path.addLine(to: CGPoint(x: s * 0.83, y: s * 0.84))
                }
                .stroke(Color(red: 0.84, green: 0.84, blue: 0.88), style: StrokeStyle(lineWidth: s * 0.045, lineCap: .round))
                Path { path in
                    path.move(to: CGPoint(x: s * 0.35, y: s * 0.43))
                    path.addLine(to: CGPoint(x: s * 0.65, y: s * 0.43))
                    path.move(to: CGPoint(x: s * 0.59, y: s * 0.37))
                    path.addLine(to: CGPoint(x: s * 0.65, y: s * 0.43))
                    path.addLine(to: CGPoint(x: s * 0.59, y: s * 0.49))
                    path.move(to: CGPoint(x: s * 0.65, y: s * 0.57))
                    path.addLine(to: CGPoint(x: s * 0.35, y: s * 0.57))
                    path.move(to: CGPoint(x: s * 0.41, y: s * 0.51))
                    path.addLine(to: CGPoint(x: s * 0.35, y: s * 0.57))
                    path.addLine(to: CGPoint(x: s * 0.41, y: s * 0.63))
                }
                .stroke(lavender, style: StrokeStyle(lineWidth: s * 0.035, lineCap: .round, lineJoin: .round))
            }
            .frame(width: s, height: s)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
