import SwiftUI

/// User-supplied Tucker reference: near-black identity band, graphite details,
/// lavender outlined website action, and native macOS title bar.
struct AboutView: View {
    private let muted = Color.white.opacity(0.64)
    private let lavender = Color(red: 0.66, green: 0.54, blue: 0.85)

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 28) {
                QuarkSwitchIcon()
                    .frame(width: 144, height: 144)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 10) {
                    Text("QuarkSwitch")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .accessibilityAddTraits(.isHeader)
                    Text("Keep your typing\nin the right language.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 36)
            .frame(height: 208)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.035, green: 0.038, blue: 0.055))

            VStack(alignment: .leading, spacing: 0) {
                Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 15) {
                    GridRow {
                        Text("Developer").foregroundStyle(muted)
                        Text("Quarks").foregroundStyle(.white.opacity(0.86))
                    }
                    GridRow {
                        Text("Requires").foregroundStyle(muted)
                        Text("macOS 15 or later").foregroundStyle(.white.opacity(0.86))
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.bottom, 26)

                Link(destination: URL(string: "https://quarks.kz")!) {
                    HStack(spacing: 16) {
                        Image(systemName: "globe")
                            .font(.system(size: 21, weight: .regular))
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Visit Developer Website")
                                .font(.system(size: 15, weight: .semibold))
                            Text("quarks.kz")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(muted)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(muted)
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(.white.opacity(0.88))
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .background(lavender.opacity(0.11), in: RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(lavender.opacity(0.35), lineWidth: 1)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Visit Quarks developer website, quarks.kz")

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.top, 25)
                    .padding(.bottom, 25)

                Text("Copyright © Quarks.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(muted)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 36)
            .padding(.top, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        }
        .frame(width: 500, height: 510)
        .environment(\.colorScheme, .dark)
    }
}

struct QuarkIdentityMark: View {
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(Color(red: 0.016, green: 0.016, blue: 0.023))
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.22)
                            .strokeBorder(Color(red: 0.37, green: 0.29, blue: 0.5).opacity(0.7), lineWidth: 1)
                    }
                    .shadow(color: Color.purple.opacity(0.16), radius: 18, x: 0, y: 9)
                Circle()
                    .trim(from: 0.06, to: 0.94)
                    .stroke(
                        AngularGradient(colors: [.white, .white.opacity(0.95), .white.opacity(0.14), .white.opacity(0.5), .white], center: .center),
                        style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round)
                    )
                    .rotationEffect(.degrees(45))
                    .frame(width: size * 0.79, height: size * 0.79)
                Path { path in
                    path.move(to: CGPoint(x: size * 0.61, y: size * 0.67))
                    path.addLine(to: CGPoint(x: size * 0.86, y: size * 0.91))
                }
                .stroke(.white.opacity(0.96), style: StrokeStyle(lineWidth: size * 0.018, lineCap: .round))
                Circle()
                    .fill(Color(red: 0.82, green: 0.67, blue: 1))
                    .frame(width: size * 0.06, height: size * 0.06)
                    .shadow(color: .purple.opacity(0.8), radius: 9, x: 0, y: 2)
                    .position(x: size * 0.75, y: size * 0.53)
            }
        }
    }
}
