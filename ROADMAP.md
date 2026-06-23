# Roadmap — PS Chile Formación

Pending and planned work. Done items live in git history, not here.

## Naming

- **App name: "PS Chile Formación".** Apply everywhere the product is named:
  - Android launcher label — `app/android/app/src/main/AndroidManifest.xml`
    (`android:label`, currently "Estatutos PS").
  - Home screen header/title — `app/lib/screens/home_screen.dart`
    (currently "Estatutos Nacionales" / "Partido Socialista de Chile").
  - `pubspec.yaml` description and any future store/listing copy.

## Next

- Verify the Allende portrait on a real device and iterate on the drawing
  (`app/lib/widgets/allende_portrait.dart`) — it was authored without a render.
- Design a proper launcher icon in the PS palette (replaces the default Flutter
  icon). Consider `flutter_launcher_icons`.

## Later

- Make the roadmap.md with Felipe

- Reader niceties: in-app search across articles, bookmarks/last-read, and
  adjustable text size.
- Quiz niceties: optional per-Título progress badges and a "repasar los fallados"
  (review missed questions) mode.
- Release build: signing config + `flutter build apk --release` / app bundle for
  distribution.
- Content freshness check: re-run `tools/parse_estatutos.ps1` when pschile.cl
  publishes a newer version (current: updated 2026-05-19).
