import Foundation

public struct LSAppInfoBadgeReader: Sendable {
    public var bundleIdentifier: String
    public var lsappinfoURL: URL

    public init(
        bundleIdentifier: String = "com.tinyspeck.slackmacgap",
        lsappinfoURL: URL = URL(fileURLWithPath: "/usr/bin/lsappinfo")
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.lsappinfoURL = lsappinfoURL
    }

    public func read() -> BadgeState {
        let infoResult = runLSAppInfo(arguments: ["info", "-only", "StatusLabel", bundleIdentifier])
        guard infoResult.status == 0 else {
            return .failed(infoResult.failureMessage)
        }

        return StatusLabelParser.parse(infoResult.stdout)
    }

    private func runLSAppInfo(arguments: [String]) -> ProcessResult {
        let process = Process()
        process.executableURL = lsappinfoURL
        process.arguments = arguments

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ProcessResult(
                status: -1,
                stdout: "",
                stderr: error.localizedDescription
            )
        }

        return ProcessResult(
            status: process.terminationStatus,
            stdout: String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "",
            stderr: String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        )
    }
}

struct ProcessResult {
    var status: Int32
    var stdout: String
    var stderr: String

    var failureMessage: String {
        let trimmedError = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedError.isEmpty {
            return trimmedError
        }

        return "lsappinfo exited with status \(status)"
    }
}
