import AppKit
import SlackActivityCore
import Sparkle

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let reader = LSAppInfoBadgeReader()
    private let iconRenderer = StatusIconRenderer()
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    private let refreshInterval: TimeInterval = 5
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var refreshTask: Task<Void, Never>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        refresh()

        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        refreshTask?.cancel()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: 20)
        item.button?.image = iconRenderer.image(for: .appNotRunning)
        item.button?.imagePosition = .imageOnly
        item.button?.imageScaling = .scaleProportionallyDown
        item.button?.toolTip = "Slack activity"
        statusItem = item
        rebuildMenu(state: .appNotRunning)
    }

    private func rebuildMenu(state: BadgeState) {
        let menu = NSMenu()

        let status = NSMenuItem(
            title: "Slack activity: \(state.displayValue)",
            action: nil,
            keyEquivalent: ""
        )
        status.isEnabled = false
        menu.addItem(status)

        menu.addItem(.separator())
        menu.addItem(actionItem(title: "Refresh", action: #selector(refreshNow), keyEquivalent: "r"))
        menu.addItem(actionItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "u"))
        menu.addItem(actionItem(title: "Open Slack", action: #selector(openSlack), keyEquivalent: "o"))
        menu.addItem(.separator())
        menu.addItem(actionItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    private func actionItem(title: String, action: Selector, keyEquivalent: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        return item
    }

    private func refresh() {
        refreshTask?.cancel()

        let reader = reader
        refreshTask = Task.detached(priority: .utility) { [weak self] in
            let state = reader.read()

            await MainActor.run {
                guard let self, !Task.isCancelled else {
                    return
                }
                self.apply(state)
            }
        }
    }

    private func apply(_ state: BadgeState) {
        statusItem?.button?.image = iconRenderer.image(for: state)
        statusItem?.button?.toolTip = "Slack activity: \(state.displayValue)"
        rebuildMenu(state: state)
    }

    @objc private func refreshNow() {
        refresh()
    }

    @objc private func checkForUpdates(_ sender: Any?) {
        updaterController.checkForUpdates(sender)
    }

    @objc private func openSlack() {
        guard let slackURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.tinyspeck.slackmacgap") else {
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: slackURL, configuration: configuration)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
