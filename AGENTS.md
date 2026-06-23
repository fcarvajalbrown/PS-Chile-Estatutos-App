# AGENTS.md — PS Chile Estatutos App

Agent-specific guide for the **PS Chile Estatutos** Flutter app. This project is a small, offline-first Android/iOS app for studying the *Estatutos Nacionales del Partido Socialista de Chile*. Read this before modifying code, content, or build configuration.

---

## Project overview

- **Product name (UI):** "Estatutos PS" (home header says "Estatutos Nacionales / Partido Socialista de Chile").
- **Planned rebrand (roadmap 1.1):** "PS Chile Formación".
- **What it does:**
  1. **Leer** — read the statute by Título and Artículo.
  2. **Curso** — a multiple-choice quiz grounded in the statute text, with three difficulty tiers (Básico / Intermedio / Avanzado) and a "repasar los fallados" review mode.
  3. **Esquemas** — visual infographics: party structure, key numbers, disciplinary procedure, electoral rules.
  4. **Mi progreso** — streak, XP, badges, and per-Título reading progress.
- **Content:** 100% offline. The statute text is bundled as JSON; quiz answers cite the article that proves them.
- **Visual identity:** Socialist Party of Chile palette (red `#D0021B`, dark red `#9C0214`, ink `#1A1A1A`, paper `#F7F3EE`). The home screen shows the party emblem; the *Acerca de* screen shows a vector outline of Salvador Allende.

---

## Technology stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (stable channel, pinned revision `e1fd963c6f6922bd32afde2e9698a363cd0406d2` per `app/.metadata`) |
| Language | Dart 3.6+ (`sdk: ">=3.6.0 <4.0.0"`) |
| State management | Plain `StatefulWidget` + `FutureBuilder` (no external state library) |
| Persistence | `shared_preferences` |
| Vector assets | `flutter_svg` (Allende outline) |
| Launcher icons | `flutter_launcher_icons` |
| Linting | `flutter_lints` + extra rules in `app/analysis_options.yaml` |
| Build host (primary) | Windows PowerShell 5.1 |
| Content pipeline | PowerShell (`tools/parse_estatutos.ps1`) and Node.js one-off scripts |

---

## Repository layout

```
PS-Chile-Estatutos-App/
├── source/                      # Authoritative statute text
│   ├── estatutos.html           # Raw download from pschile.cl (reference)
│   ├── estatutos.txt            # Full stripped text (includes site chrome)
│   └── estatutos_clean.txt      # Verbatim statute body — parser input
├── tools/                       # Content / scaffolding scripts
│   ├── parse_estatutos.ps1      # source/estatutos_clean.txt → app/assets/data/estatutos.json
│   ├── add_difficulty.js        # One-off: injected difficulty tiers into quiz.json
│   ├── scaffold.ps1             # Generates app/android/ without clobbering lib/assets
│   └── scaffold_ios.ps1         # Generates app/ios/ without clobbering lib/assets
├── app/                         # Flutter project
│   ├── pubspec.yaml             # Dependencies, assets, launcher-icon config
│   ├── analysis_options.yaml    # Lints (prefer_const*, avoid_print)
│   ├── assets/
│   │   ├── data/
│   │   │   ├── estatutos.json   # GENERATED reading content
│   │   │   ├── quiz.json        # Quiz bank (hand-authored, grounded in articles)
│   │   │   ├── callouts.json    # Reader callout boxes
│   │   │   └── factboxes.json   # "Datos clave" tables
│   │   └── img/                 # Emblem, Allende outline, full logo
│   ├── android/                 # Native Android scaffolding (generated)
│   ├── ios/                     # Native iOS scaffolding (generated)
│   └── lib/
│       ├── main.dart            # Entry point, MaterialApp, theme
│       ├── theme.dart           # PS palette and ThemeData
│       ├── models.dart          # Estatuto/Titulo/Articulo/QuizQuestion/Callout/FactBox/Tier
│       ├── repository.dart      # Asset loading + shared_preferences progress
│       ├── badges.dart          # Badge definitions (class Logro)
│       ├── screens/
│       │   ├── home_screen.dart
│       │   ├── reader_screen.dart      # Título list + article reader
│       │   ├── quiz_setup_screen.dart  # Tier/scope selection
│       │   ├── quiz_screen.dart        # Quiz session UI
│       │   ├── progreso_screen.dart    # Stats, badges, reading progress
│       │   ├── esquemas_screen.dart    # Infographics
│       │   └── acerca_screen.dart      # About + reset progress
│       └── widgets/
│           ├── allende_portrait.dart   # CustomPaint portrait (unused in current UI; SVG is used)
│           ├── callout_box.dart
│           └── fact_box.dart
├── README.md                    # Setup instructions (Spanish)
├── CLAUDE.md                    # Project-specific rules, party facts, content integrity
├── ROADMAP.md                   # 1.1 → 2.0+ milestones
└── .gitignore
```

---

## Build and run commands

All Flutter commands run from the `app/` directory.

```bash
cd app
flutter pub get
flutter run                # debug on connected emulator/device
flutter run --release      # release on device
flutter build apk --release
# APK output: app/build/app/outputs/flutter-apk/app-release.apk
```

iOS (must be done on a Mac):

```bash
cd app
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
flutter run
```

### Initial repo setup (no `android/` or `ios/`)

This repo intentionally does **not** commit platform-agnostic generated files like `.dart_tool/`, `build/`, or some ephemeral native files, but it **does** commit `android/` and `ios/`. If they are missing, regenerate them without touching `lib/`, `assets/`, or `pubspec.yaml`:

```powershell
powershell -ExecutionPolicy Bypass -File tools\scaffold.ps1
powershell -ExecutionPolicy Bypass -File tools\scaffold_ios.ps1
```

---

## Content pipeline — critical rules

The statute text in the app is **generated**, not hand-edited.

1. **Source of truth:** `source/estatutos_clean.txt` — the verbatim statute body (Título I through Disposiciones Transitorias), copied/derived from `https://www.pschile.cl/estatutos/` (version updated `2026-05-19`).
2. **Do not hand-edit `app/assets/data/estatutos.json`.** To change reading content, edit `source/estatutos_clean.txt`, then regenerate:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\parse_estatutos.ps1
   ```

3. **Quiz content** lives in `app/assets/data/quiz.json`. Each question must have:
   - `articleRef` pointing to the article that proves the correct answer.
   - `correct` index matching that article's text.
   - `difficulty` in `{1,2,3}`.
   Distractors are the only invented strings; they must never be defensibly correct.
4. **Callouts / fact boxes** live in `app/assets/data/callouts.json` and `factboxes.json`. They are keyed by `articleId` = `"<roman>#<number>"` (e.g. `"IV#12"`, `"TRANS#primero"`). Fact boxes must be data-driven and verifiable against the statute.

When updating content, verify the official site version and document the new date in `source/`, the parser output, and relevant UI copy.

---

## Code style guidelines

- **UI language:** Spanish (Chilean). **Code identifiers and comments:** English.
- **Colors / fonts:** Use only `lib/theme.dart` (`PSColors`, `buildPSTheme()`). Do not hardcode colors in widgets.
- **Const correctness:** Enabled via `analysis_options.yaml` (`prefer_const_constructors`, `prefer_const_declarations`). Keep `const` where possible.
- **No print statements:** `avoid_print: true` is enforced.
- **Formatting:** Standard `dart format` style.
- **Private widgets:** Use underscore-prefixed private classes/state/widgets within the same file for screen-local helpers.
- **Strings:** User-facing strings are inline Spanish literals. Avoid externalizing to ARB files unless a localization feature is explicitly requested.

---

## Testing instructions

There are currently **no automated tests** in this repository. The project relies on:

- `flutter analyze` for static analysis.
- Manual runtime testing on Android emulator/device and iOS simulator/device.
- Content integrity review: verify generated `estatutos.json` matches `source/estatutos_clean.txt`, and that every quiz `articleRef` exists in the statute.

To add tests, place them under `app/test/` following Flutter's standard `flutter_test` conventions. Run tests with:

```bash
cd app
flutter test
```

---

## Security and content integrity

- **Never invent or paraphrase statute text.** Every word shown in *Leer* must come verbatim from `source/`.
- **Never invent party facts** (founding date, slogans, leadership, ideology). Verify against `CLAUDE.md` or authoritative sources.
- **No network calls at runtime.** The app must remain fully offline; all content is bundled.
- **Do not commit signing keys.** Keystore/JKS files are ignored in `.gitignore`.
- The Android release build currently uses the debug signing config (`signingConfig = signingConfigs.getByName("debug")`). Production release builds need a real signing configuration in `app/android/app/build.gradle.kts`.

---

## Deployment processes

- **Android debug:** `flutter run`.
- **Android release APK:** `flutter build apk --release`.
- **Android app bundle (Play Store):** `flutter build appbundle --release` (requires release signing config).
- **iOS:** Open `app/ios/Runner.xcworkspace` in Xcode, configure signing/team, then `flutter run` or archive via Xcode.
- **Launcher icons:** After editing `assets/img/ps_emblem.png` or `assets/img/ps_emblem_padded.png`, regenerate:

  ```bash
  cd app
  dart run flutter_launcher_icons
  ```

---

## Conventions specific to this codebase

- `Repository` is a single offline data/progress service. It loads JSON assets via `rootBundle` and persists progress via `SharedPreferences`.
- Article IDs use the form `"<roman>#<number>"` (e.g. `"V#17"`, `"VI#19 bis"`). The transitory block uses `"TRANS"`.
- Quiz question stable IDs are derived in `models.dart` as `"$titulo|$articleRef|$question"` and are used for "missed question" tracking.
- Progress keys in `SharedPreferences`:
  - `read_articles` — list of read article IDs.
  - `missed_questions` — list of missed quiz question IDs.
  - `best_<scope>_<tier>` — best quiz percentage per scope/tier.
  - `gam_xp`, `gam_streak`, `gam_lastday`, `gam_badges` — gamification state.
- The `Tier` enum maps difficulty levels: `basico=1`, `intermedio=2`, `avanzado=3`.

---

## Useful references

- `README.md` — end-user setup (Flutter SDK install, Windows PowerShell).
- `CLAUDE.md` — stricter content-integrity rules, party facts, process rules.
- `ROADMAP.md` — planned milestones (1.1 mid-article fact boxes → 2.0 content completeness).
- Official statute source: `https://www.pschile.cl/estatutos/`.
