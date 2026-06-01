.PHONY: build test run app package dmg appcast notarize open clean

build:
	swift build

test:
	swift test

run:
	swift run SlackActivityMenu

app:
	./scripts/build_app.sh

package:
	./scripts/package_release.sh

dmg:
	./scripts/package_dmg.sh

appcast:
	./scripts/generate_appcast.sh

notarize:
	./scripts/notarize.sh

open: app
	open .build/SlackActivityMenu.app

clean:
	rm -rf .build
