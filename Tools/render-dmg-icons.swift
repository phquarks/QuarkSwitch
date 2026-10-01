import AppKit
import SwiftUI

@main
struct RenderDMGIcons {
    @MainActor
    static func main() throws {
        guard CommandLine.arguments.count == 2 else { fatalError("Supply staging directory") }
        let staging = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let renderer = ImageRenderer(content: QuarkSwitchIcon().frame(width: 1024, height: 1024))
        renderer.scale = 1
        guard let image = renderer.cgImage,
              let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
            fatalError("Unable to render the existing QuarkSwitch identity mark")
        }
        try png.write(to: staging.appendingPathComponent("app-icon.png"))

        // Finder has a shared icon size. A small document on a transparent
        // canvas gives the guide a smaller visual size without AppleScript.
        let guideIcon = NSImage(size: NSSize(width: 256, height: 256))
        guideIcon.lockFocus()
        if let symbol = NSImage(systemSymbolName: "doc.text.fill", accessibilityDescription: nil) {
            symbol.draw(in: NSRect(x: 71, y: 55, width: 114, height: 146))
        }
        guideIcon.unlockFocus()
        guard NSWorkspace.shared.setIcon(
            guideIcon, forFile: staging.appendingPathComponent("Installation Guide.txt").path, options: []
        ) else { fatalError("Unable to set the smaller guide icon") }
    }
}
