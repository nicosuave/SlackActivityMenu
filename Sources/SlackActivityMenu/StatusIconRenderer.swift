import AppKit
import SlackActivityCore

@MainActor
final class StatusIconRenderer {
    private var imageCache: [String: NSImage] = [:]

    func image(for state: BadgeState) -> NSImage {
        let badgeText = textForBadge(state)
        let cacheKey = badgeText ?? "none"
        if let cached = imageCache[cacheKey] {
            return cached
        }

        let iconSize: CGFloat = 17
        let badgeHeight: CGFloat = 11
        let horizontalPadding: CGFloat = 3
        let attributes = badgeAttributes
        let textWidth = badgeText.map { ceil($0.size(withAttributes: attributes).width) } ?? 0
        let badgeWidth = badgeText == nil ? 0 : min(17, max(badgeHeight, textWidth + horizontalPadding * 2))
        let canvasWidth: CGFloat = 19
        let canvasHeight: CGFloat = 19
        let size = NSSize(width: canvasWidth, height: canvasHeight)

        let image = NSImage(size: size)
        image.lockFocus()

        let iconRect = NSRect(x: 0, y: 1, width: iconSize, height: iconSize)
        drawActivityMark(in: iconRect)

        if let badgeText {
            let badgeRect = NSRect(
                x: canvasWidth - badgeWidth - 1,
                y: canvasHeight - badgeHeight,
                width: badgeWidth,
                height: badgeHeight
            )
            drawBadge(text: badgeText, in: badgeRect, attributes: attributes)
        }

        image.unlockFocus()
        image.isTemplate = false
        imageCache[cacheKey] = image
        return image
    }

    private func textForBadge(_ state: BadgeState) -> String? {
        guard case let .label(value) = state else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "0" else {
            return nil
        }

        guard let count = Int(trimmed) else {
            return trimmed
        }

        if count > 99 {
            return "99+"
        }

        return String(count)
    }

    private func drawBadge(
        text: String,
        in rect: NSRect,
        attributes: [NSAttributedString.Key: Any]
    ) {
        NSColor.systemRed.setFill()
        NSBezierPath(
            roundedRect: rect,
            xRadius: rect.height / 2,
            yRadius: rect.height / 2
        ).fill()

        let textSize = text.size(withAttributes: attributes)
        let textRect = NSRect(
            x: rect.midX - textSize.width / 2,
            y: rect.midY - textSize.height / 2 - 0.5,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
    }

    private func drawActivityMark(in rect: NSRect) {
        NSColor.black.setFill()

        let stroke = max(2.2, rect.width * 0.18)
        let radius = stroke / 2
        let verticalOne = NSRect(
            x: rect.minX + rect.width * 0.28,
            y: rect.minY + rect.height * 0.08,
            width: stroke,
            height: rect.height * 0.84
        )
        let verticalTwo = NSRect(
            x: rect.minX + rect.width * 0.58,
            y: rect.minY + rect.height * 0.08,
            width: stroke,
            height: rect.height * 0.84
        )
        let horizontalOne = NSRect(
            x: rect.minX + rect.width * 0.08,
            y: rect.minY + rect.height * 0.31,
            width: rect.width * 0.84,
            height: stroke
        )
        let horizontalTwo = NSRect(
            x: rect.minX + rect.width * 0.08,
            y: rect.minY + rect.height * 0.61,
            width: rect.width * 0.84,
            height: stroke
        )

        NSBezierPath(roundedRect: verticalOne, xRadius: radius, yRadius: radius).fill()
        NSBezierPath(roundedRect: verticalTwo, xRadius: radius, yRadius: radius).fill()
        NSBezierPath(roundedRect: horizontalOne, xRadius: radius, yRadius: radius).fill()
        NSBezierPath(roundedRect: horizontalTwo, xRadius: radius, yRadius: radius).fill()
    }

    private var badgeAttributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 7.5, weight: .bold),
            .foregroundColor: NSColor.white,
        ]
    }
}
