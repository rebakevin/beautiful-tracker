## Group 24

# Beautiful Tracker

A mobile project & SLA task tracker for small software teams, built with Flutter.

## Getting started

```bash
flutter pub get
flutter run   # on an Android emulator / iOS simulator or a physical device
```

No emulator? Run it in Chrome for development:

```bash
flutter run -d chrome
```

The graded demo must still run on an emulator or a physical device.

## Project structure

```
lib/
├── main.dart                 # Entry point: loads settings, restores the session
├── app.dart                  # Root state (user, dark mode), MaterialApp, auth gate
├── core/
│   ├── session/              # SessionScope: signed-in user + dark mode for all screens
│   ├── theme/                # Design tokens: colors, light/dark palette, ThemeData
│   └── utils/                # Form validators, password hashing
├── data/
│   ├── local/                # SQLite database helper, SharedPreferences settings
│   ├── models/               # Plain data classes (AppUser, ...)
│   ├── repositories/         # Read/write one table each (UserRepository, ...)
│   └── services/             # Rules that use the repositories (AccountService)
├── features/                 # One folder per tab / feature
│   ├── auth/                 # Sign in, sign up
│   ├── dashboard/
│   ├── tasks/
│   ├── members/
│   └── profile/              # Profile, edit profile, change password
├── navigation/               # Bottom-navigation shell for the main tabs
└── widgets/                  # Reusable widgets shared across features
```

New screens go in their feature folder; widgets used by more than one feature
go in `widgets/` (labeled text field, buttons, avatar, toast, confirm dialog,
form page). Use `context.palette` for colors so screens follow dark mode.

## Local storage

| What | Where | Why |
| --- | --- | --- |
| Accounts (and later tasks, members) | SQLite via `sqflite` | Structured records with relations and unique constraints |
| Signed-in user id, dark mode | SharedPreferences | Small key-value settings read once at startup |

`DatabaseHelper` in `lib/data/local/database_helper.dart` opens a single shared
database. Schema changes are numbered migrations: to add a table, add an entry
to `_migrations` and bump `_version` to the same number. Never edit a migration
that has already been pushed, and tell the team which version number you are
taking so two branches do not use the same one.

Passwords are stored as a salted SHA-256 hash, never as plain text. There is no
backend: sign-in is a demo where any valid email and a 6+ character password
works, and an account is created on first sign-in if the email is new.

On web, `sqflite` has no browser implementation, so the helper switches to
`sqflite_common_ffi_web`: a WebAssembly build of SQLite stored in the browser's
IndexedDB. It uses `web/sqlite3.wasm` and `web/sqflite_sw.js`; to regenerate
them after upgrading the package, run `dart run sqflite_common_ffi_web:setup`.
