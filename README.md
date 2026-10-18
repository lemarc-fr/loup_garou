# Thiercelieux (loup_garou)

Companion app for playing *Loups-Garous de Thiercelieux* around a single phone
(pass-and-play). Built with Flutter for Android, iOS and the web.

- [Packages: why each one is here](#packages-why-each-one-is-here)
- [Updating packages](#updating-packages)
- [Android build settings](#android-build-settings)
- [Night sound files](#night-sound-files)
- [Tests](#tests)

## Packages: why each one is here

Declared in [pubspec.yaml](pubspec.yaml). Every package below is actually
imported by the app; unused ones are removed.

### App (`dependencies`)

| Package | Why it is needed | Used in |
|---|---|---|
| `flutter_localizations` (SDK) | French / English translations of Flutter's own widgets (buttons, dialogs…). Our texts come from `lib/l10n/*.arb`. | `lib/l10n/app_localizations.dart` (generated) |
| `flutter_svg` | Draws `.svg` images (the howling wolf, `assets/images/wolf_howling.svg`). Flutter cannot show SVG on its own. | `lib/widgets/night_scene.dart` |
| `provider` | Shares the game state (`GameProvider`) and the settings (`SettingsProvider`) with every screen, and rebuilds screens when they change. | almost everywhere |
| `shared_preferences` | Saves small data on the phone: settings, language and player statistics. | `lib/services/storage_service.dart` |
| `google_fonts` | The two fonts of the "night" theme: *Cinzel* (titles) and *Work Sans* (text). The files used are bundled in `assets/google_fonts/` (with their OFL licenses) and runtime downloads are disabled, so the app works offline from the first launch. A new weight must be added there (`test/theme/bundled_fonts_test.dart` fails otherwise). | `lib/theme/app_theme.dart`, `lib/main.dart` |
| `uuid` | Unique ids for the players of a game. | `lib/services/game_engine.dart` |
| `intl` | Required by the generated translation code (plurals, French/English rules). | `lib/l10n/app_localizations*.dart` (generated) |
| `audioplayers` | Plays the narrator's voice, the night music and sound effects (`assets/audio/`). | `lib/services/sound_service.dart` |

### Development only (`dev_dependencies`, not shipped in the app)

| Package | Why it is needed |
|---|---|
| `flutter_test` (SDK) | Runs the tests in `test/` (`flutter test`). |
| `integration_test` (SDK) | Runs the full-game test in `integration_test/` on a device. |
| `flutter_driver` (SDK) | Receives the screenshots taken on the device by `integration_test/screenshots_test.dart` (`test_driver/screenshots.dart`). |
| `flutter_lints` | The code rules checked by `flutter analyze`. |
| `flutter_launcher_icons` | Generates the app icon for Android and iOS from `assets/icon/icon.png` (`dart run flutter_launcher_icons`). |

### Removed

| Package | Why it was removed |
|---|---|
| `flutter_tts` | Read a phrase with the phone's text-to-speech when its mp3 was missing. Every phrase now has an mp3 in every language (checked by `test/services/voice_assets_test.dart`), so it was never used. It also blocked the Android build (see below). |
| `cupertino_icons`, `flutter_animate`, `mocktail` | Never imported. |

## Updating packages

```sh
flutter pub upgrade --major-versions   # latest versions, even breaking ones
flutter pub upgrade --tighten          # write those versions into pubspec.yaml
flutter pub outdated                   # what is still not on the latest version
flutter analyze && flutter test        # check nothing broke
```

`flutter pub outdated` may still list a few *transitive* packages (packages
used by our packages, e.g. `xml`, `test_api`). Their version is chosen by the
Flutter SDK or by another package: nothing to do on our side.

**google_fonts 9 note:** `GoogleFonts.xxxTextTheme()` now returns a
`TextTheme` from the new `material_ui` package, which Flutter's own
`ThemeData` does not accept. `lib/theme/app_theme.dart` therefore builds the
Work Sans `TextTheme` itself (`_workSansTextTheme`). Individual styles
(`GoogleFonts.cinzel(...)`) are not affected.

## Android build settings

The Android build is configured by four files in `android/`. When updating,
use the latest **stable** versions, and keep the CI (`.github/workflows/`) on
the same Flutter version as your machine (`flutter --version`).

| What | File | Current |
|---|---|---|
| Flutter version (CI) | `.github/workflows/build_mobile.yml` and `build_web.yml` → `FLUTTER_VERSION` | 3.47.7 |
| Gradle (the build tool) | `android/gradle/wrapper/gradle-wrapper.properties` → `distributionUrl` | 9.8.1 |
| Android Gradle Plugin (AGP) | `android/settings.gradle.kts` → `com.android.application` | 9.4.1 |
| Kotlin | `android/settings.gradle.kts` → `org.jetbrains.kotlin.android` | 2.4.21 |
| AGP options | `android/gradle.properties` | see below |

Where to find the latest versions:
[Gradle](https://gradle.org/releases/),
[AGP](https://developer.android.com/build/releases/gradle-plugin),
[Kotlin](https://kotlinlang.org/docs/releases.html),
[Flutter](https://docs.flutter.dev/release/archive).

### The two AGP options in `gradle.properties`

- **`android.newDsl=false`**: AGP 9 changed how build files are read (the
  "new DSL"). The Flutter plugin on stable Flutter (3.47) still uses the old
  one, so this line is **required**. Without it the build fails with
  *"ApplicationExtensionImpl… cannot be cast to AbstractAppExtension"*.
  Remove it only when a stable Flutter release says it supports the new DSL
  (the build will tell you, or see
  [flutter/flutter#180137](https://github.com/flutter/flutter/issues/180137)).
- **`android.builtInKotlin=true`**: AGP 9 compiles Kotlin by itself. The
  Kotlin line in `settings.gradle.kts` is `apply false`: it is not applied,
  it only sets the Kotlin version (otherwise AGP uses its own older one and
  Flutter refuses it: *"Kotlin version (2.2.10) is lower than Flutter's
  minimum…"*).

### If a package breaks the build with "kotlin-android"

Some Flutter packages still use the old way to compile Kotlin. With built-in
Kotlin the build then fails with *"Failed to apply plugin 'kotlin-android'"*
and names the package. Either replace the package, or switch back to the old
Kotlin setup until the package is updated:

1. `android/gradle.properties`: `android.builtInKotlin=false`
2. `android/app/build.gradle.kts`: add `id("org.jetbrains.kotlin.android")`
   in `plugins { }`, between `com.android.application` and
   `dev.flutter.flutter-gradle-plugin`.

Undo both changes once the package is fixed. Flutter will stop supporting the
old setup in a future version.

## Night sound files

See [tool/audio/README.md](tool/audio/README.md) to generate the narrator's
voice files, the music and the sound effects.

## Tests

```sh
flutter test                                 # everything (~2 min)
flutter test test/services                   # game rules only (~15 s)
flutter test integration_test/full_game_flow_test.dart -d <device>   # full game on a phone/emulator
```

| Where | What it checks |
|---|---|
| `test/services/game_engine*_test.dart` | Each rule on its own: night order, every role, votes, mayor, follow-ups of a death, win conditions. |
| `test/services/full_game_scenario_test.dart` | A scripted 18-player game (7 nights) using almost every role, with checks at each step. |
| `test/services/random_games_test.dart` | 600 complete games with random roles, settings and choices; game invariants are checked after every action. A failure prints the seed and the action log. |
| `test/widgets/full_game_ui_test.dart` | The same 18-player game played in the real app by tapping every screen, from home back to home. |
| `test/widgets/random_games_ui_test.dart` | Random games (12–16 players, in English) played through the UI. |
| `test/providers`, `test/models`, other `test/widgets` | Setup wizard, statistics, JSON, individual screens. |

Shared helpers live in `test/support/`: `game_fixtures.dart` (games with chosen
cards), `game_decisions.dart` (player choices, scripted or random),
`engine_runner.dart` (plays a game on the engine and checks invariants),
`ui_game_driver.dart` (plays the same choices by tapping the screens) and
`village_scenario.dart` (the 18-player game). Everything random is seeded, so a
failing game replays exactly.

## Screenshots

`integration_test/screenshots_test.dart` replays the 18-player game and
captures 15 screens (home, setup, night roles, votes, end of game), in French
and in English. `UiGameDriver.onScreen` names each screen; edit the `screens`
list to choose them.

```sh
SCREENSHOT_DIR=screenshots flutter drive -d <device>   --driver=test_driver/screenshots.dart   --target=integration_test/screenshots_test.dart
```

The **Screenshots** workflow (`.github/workflows/screenshots.yml`) runs it on
an iPhone 6.3" and an iPad 13" simulator through
`.github/scripts/screenshots.sh`, at sizes App Store Connect accepts. The
files are in the run's `app-store-screenshots` artifact
(`<iphone|ipad>/<fr|en>/NN-screen.png`).
