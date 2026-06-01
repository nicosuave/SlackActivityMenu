# SlackActivityMenu

A tiny macOS menu bar app that mirrors Slack's local activity badge label.

This project is unofficial and is not affiliated with, endorsed by, or supported by Slack Technologies, LLC or Salesforce.

It uses Slack's `StatusLabel` value from LaunchServices and renders it as a compact red badge over a custom black activity mark. This is useful for surfacing Slack activity while the Dock is hidden or out of view.

## What It Is

`SlackActivityMenu` is a local-only utility. It does not use Slack OAuth, Slack Web API tokens, network calls, or notification scraping.

The app runs as a menu extra, polls every 5 seconds, and reads:

```sh
/usr/bin/lsappinfo info -only StatusLabel com.tinyspeck.slackmacgap
```

That value is Slack's local activity label. It can be a dot, a count, or empty depending on Slack's own state and preferences. It is not a semantic unread-message API.

## Install From Source

```sh
cd ~/Code/SlackActivityMenu
make open
```

The generated app bundle is:

```text
~/Code/SlackActivityMenu/.build/SlackActivityMenu.app
```

## Development

```sh
swift test
swift run SlackActivityMenu
```

Useful make targets:

```sh
make build
make test
make app
make package
make notarize
make open
make clean
```

## Release Builds

Build a local `.app` bundle:

```sh
make app
```

Build, sign, and zip with a Developer ID Application certificate:

```sh
make package
```

Notarize with an existing notarytool keychain profile:

```sh
make notarize
```

The build scripts generate the app icon, write `Info.plist`, sign with hardened runtime for release packaging, and produce zip archives under `.build/`.

For repeatable local release settings, copy `.release.env.example` to `.release.env` and set your signing identity and notarytool profile. `.release.env` is ignored so credentials and machine-specific profile names are not committed.

If the notary profile is not already configured, create it once:

```sh
xcrun notarytool store-credentials notarytool \
  --apple-id you@example.com \
  --team-id TEAMID \
  --password app-specific-password
```

## Limitations

- macOS does not provide a public API for reading another app's badge label.
- `lsappinfo StatusLabel` is a private LaunchServices diagnostic surface.
- Slack must be running and registered with LaunchServices.
- The local value may reflect activity, mentions, DMs, workspace aggregation, Slack preferences, or simply a dot.
- Individual unread item details are not available through this local path.

Without Slack's official API, alternatives such as Accessibility scraping, Notification Center history, or reverse-engineering Slack's Electron storage are brittle and incomplete.

## Icon

The menu icon is a custom abstract hash/activity mark drawn by the app. It is not Slack's logo.

## License

MIT. See [LICENSE](LICENSE).
