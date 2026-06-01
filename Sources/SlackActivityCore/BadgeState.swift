import Foundation

public enum BadgeState: Equatable, Sendable {
    case appNotRunning
    case noBadge
    case label(String)
    case failed(String)

    public var label: String? {
        if case let .label(value) = self {
            return value
        }
        return nil
    }

    public var displayValue: String {
        switch self {
        case .appNotRunning:
            return "not running"
        case .noBadge:
            return "0"
        case let .label(value):
            return value
        case let .failed(message):
            return "error: \(message)"
        }
    }
}

extension BadgeState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .appNotRunning:
            return "app-not-running"
        case .noBadge:
            return "no-badge"
        case let .label(value):
            return value
        case let .failed(message):
            return "failed: \(message)"
        }
    }
}
