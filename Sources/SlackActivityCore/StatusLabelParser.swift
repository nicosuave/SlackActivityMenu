import Foundation

enum StatusLabelParser {
    static func parse(_ output: String) -> BadgeState {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .appNotRunning
        }

        if trimmed.contains("[ NULL ]") {
            return .noBadge
        }

        if let label = extractLabel(from: trimmed) {
            if label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .noBadge
            }

            return .label(label)
        }

        return .failed("unrecognized StatusLabel output: \(trimmed)")
    }

    private static func extractLabel(from value: String) -> String? {
        guard let labelRange = value.range(of: "\"label\"=") else {
            return nil
        }

        var remainder = value[labelRange.upperBound...]
        guard remainder.first == "\"" else {
            return nil
        }

        remainder.removeFirst()

        var result = ""
        var isEscaped = false

        for character in remainder {
            if isEscaped {
                result.append(character)
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "\"" {
                return result
            } else {
                result.append(character)
            }
        }

        return nil
    }
}
