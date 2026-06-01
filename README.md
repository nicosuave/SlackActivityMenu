# SlackActivityMenu

A tiny macOS menu bar app that mirrors Slack's local activity badge label.

This project is unofficial and is not affiliated with, endorsed by, or supported by Slack Technologies, LLC or Salesforce.

It uses Slack's `StatusLabel` value from LaunchServices and renders it as a compact red badge over a custom black activity mark. This is useful for surfacing Slack activity while the Dock is hidden or out of view.

![SlackActivityMenu showing a red activity badge in the macOS menu bar](docs/menu-bar-badge.png)

## What It Is

`SlackActivityMenu` is a local-only utility. It does not use Slack OAuth, Slack Web API tokens, network calls, or notification scraping. It does use Sparkle to check for app updates from this project's GitHub releases.

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
make dmg
make appcast
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

Build and sign a drag-to-Applications disk image:

```sh
make dmg
```

Notarize with an existing notarytool keychain profile:

```sh
make notarize
```

The build scripts generate the app icon, write `Info.plist`, sign with hardened runtime for release packaging, and produce zip and DMG archives under `.build/`. `make notarize` notarizes and staples both the app bundle and release DMG, then generates a Sparkle `appcast.xml` for the versioned DMG under `.build/appcast/`.

For repeatable local release settings, copy `.release.env.example` to `.release.env` and set your signing identity, notarytool profile, Sparkle account, and optional DMG volume name. `.release.env` is ignored so credentials and machine-specific profile names are not committed.

If the notary profile is not already configured, create it once:

```sh
xcrun notarytool store-credentials notarytool \
  --apple-id you@example.com \
  --team-id TEAMID \
  --password app-specific-password
```

Sparkle update signing uses an EdDSA private key stored in Keychain. Create or print the matching public key with:

```sh
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account com.nicholasritschel.SlackActivityMenu
```

Do not commit exported Sparkle private keys.

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
