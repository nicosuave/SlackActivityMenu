#!/usr/bin/env swift

import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("usage: generate_app_icon.swift <iconset-dir>\n", stderr)
    exit(64)
}

let iconsetURL = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let iconFiles: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

for (filename, size) in iconFiles {
    let data = pngData(size: size)
    try data.write(to: iconsetURL.appendingPathComponent(filename))
}

func pngData(size: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [.alphaFirst],
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!

    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.cgContext.setShouldAntialias(true)
    drawIcon(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    return rep.representation(using: .png, properties: [:])!
}

func drawIcon(in rect: NSRect) {
    let backgroundRect = rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.08)
    let cornerRadius = rect.width * 0.22
    let backgroundPath = NSBezierPath(
        roundedRect: backgroundRect,
        xRadius: cornerRadius,
        yRadius: cornerRadius
    )

    NSGradient(
        colors: [
            NSColor(calibratedWhite: 0.10, alpha: 1),
            NSColor(calibratedWhite: 0.02, alpha: 1),
        ]
    )?.draw(in: backgroundPath, angle: 270)

    drawActivityMark(in: backgroundRect.insetBy(dx: rect.width * 0.20, dy: rect.height * 0.20))

    let badgeSize = rect.width * 0.25
    let badgeRect = NSRect(
        x: backgroundRect.maxX - badgeSize * 0.95,
        y: backgroundRect.maxY - badgeSize * 0.95,
        width: badgeSize,
        height: badgeSize
    )
    NSColor.systemRed.setFill()
    NSBezierPath(ovalIn: badgeRect).fill()
}

func drawActivityMark(in rect: NSRect) {
    NSColor.white.setFill()

    let stroke = rect.width * 0.18
    let radius = stroke / 2
    let center = NSPoint(x: rect.midX, y: rect.midY)
    let verticalInset = rect.height * 0.05
    let horizontalInset = rect.width * 0.05

    fillRotatedRoundedRect(
        NSRect(
            x: rect.minX + rect.width * 0.28,
            y: rect.minY + verticalInset,
            width: stroke,
            height: rect.height - verticalInset * 2
        ),
        radius: radius,
        degrees: 8,
        center: center
    )
    fillRotatedRoundedRect(
        NSRect(
            x: rect.minX + rect.width * 0.58,
            y: rect.minY + verticalInset,
            width: stroke,
            height: rect.height - verticalInset * 2
        ),
        radius: radius,
        degrees: 8,
        center: center
    )
    fillRotatedRoundedRect(
        NSRect(
            x: rect.minX + horizontalInset,
            y: rect.minY + rect.height * 0.31,
            width: rect.width - horizontalInset * 2,
            height: stroke
        ),
        radius: radius,
        degrees: -8,
        center: center
    )
    fillRotatedRoundedRect(
        NSRect(
            x: rect.minX + horizontalInset,
            y: rect.minY + rect.height * 0.61,
            width: rect.width - horizontalInset * 2,
            height: stroke
        ),
        radius: radius,
        degrees: -8,
        center: center
    )
}

func fillRotatedRoundedRect(_ rect: NSRect, radius: CGFloat, degrees: CGFloat, center: NSPoint) {
    var transform = AffineTransform(translationByX: center.x, byY: center.y)
    transform.rotate(byDegrees: degrees)
    transform.translate(x: -center.x, y: -center.y)

    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    path.transform(using: transform)
    path.fill()
}
