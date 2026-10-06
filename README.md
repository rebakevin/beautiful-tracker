## Group 24

# Beautiful Tracker

A mobile project & SLA task tracker for small software teams, built with Flutter.

## Getting started

```bash
flutter pub get
flutter run   # on an Android emulator / iOS simulator or a physical device
```

## Project structure

```
lib/
├── main.dart                 # Entry point: initialises bindings + database
├── app.dart                  # MaterialApp, theme and home route
├── core/
│   └── theme/                # Design tokens: colors, spacing/radius, ThemeData
├── data/
│   └── local/                # SQLite (sqflite) database helper
├── features/                 # One folder per tab / feature
│   ├── dashboard/
│   ├── tasks/
│   ├── members/
│   └── profile/
├── navigation/               # Bottom-navigation shell for the main tabs
└── widgets/                  # Reusable widgets shared across features
```

New screens go in their feature folder; widgets used by more than one feature
go in `widgets/`.

## Local storage

Data is stored locally with SQLite via `sqflite`. `DatabaseHelper` in
`lib/data/local/database_helper.dart` opens a single shared database. To add or
change tables, create them in `_onCreate`, bump `_version`, and add the
migration in `_onUpgrade`.
