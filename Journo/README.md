# Journo

Journo is a minimal, privacy-first, cross-platform journal app built with Flutter.

Supported platforms: Android, Windows, Linux, macOS.

## Features

- Create, edit, and delete journal entries
- Local-first storage using JSON on device
- Search and filter by date
- Daily quote (from `assets/quotes.json`)

## Getting Started

1. Install Flutter (`>=3.22.0`).
2. Enable desktop platforms as needed (`flutter config --enable-linux-desktop`, `--enable-windows-desktop`, `--enable-macos-desktop`).
3. From project root:
   ```bash
   flutter pub get
   flutter run
   ```

The `lib` directory is a symlink to `src` for a clearer app structure.

## Project Structure

```
Journo/
 ├── assets/          # Quotes, icons, logo
 ├── src/             # App source code (symlinked as lib/ for Flutter)
 ├── README.md
 └── LICENSE
```

## License

MIT
