# Publishing Checklist

## Before Public Release

- Review descriptive Slack name usage and trademark implications.
- Decide whether to publish source-only, binary releases, or both.

## Technical Notes

- This app depends on `/usr/bin/lsappinfo` and the private `StatusLabel` field.
- The displayed value is Slack's local activity label, not a guaranteed unread message count.
- There is no local, supported path for individual unread item details.
- The app does not use Slack API credentials, network calls, or Notification Center history.
- Sparkle checks for app updates from the GitHub-hosted appcast.

## Verification

```sh
swift test
make app
make package
make dmg
make notarize
```

For repeatable local release settings, copy `.release.env.example` to `.release.env` and set `CODESIGN_IDENTITY`, `NOTARY_PROFILE`, `SPARKLE_ACCOUNT`, and optionally `DMG_VOLUME_NAME`.

If notarization credentials are missing:

```sh
xcrun notarytool store-credentials notarytool \
  --apple-id you@example.com \
  --team-id TEAMID \
  --password app-specific-password
```

If Sparkle signing credentials are missing:

```sh
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account com.nicholasritschel.SlackActivityMenu
```

Release uploads should include `.build/appcast/SlackActivityMenu-$APP_VERSION.dmg` and `.build/appcast/appcast.xml`.
