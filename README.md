# PassForge — KDE Plasma 6

PassForge is a KDE Plasma 6 widget that generates secure passwords and memorable passphrases. It provides two generators in a native Plasma interface, with configurable character sets, word selection, and password options.

PassForge uses Qt's system-backed cryptographic random number generator through a small C++ QML module named `OpenSquares.PassForge`.

## Features

### Password Generator

- Generate passwords with configurable lengths from 5 to 128 characters.
- Choose from four character sets:
  - Uppercase letters (`A-Z`)
  - Lowercase letters (`a-z`)
  - Numbers (`0-9`)
  - Special characters (`!@#$%^&*`)
- Configure minimum numbers and special characters in each generated password.
- Automatically shuffle generated characters to distribute required characters throughout the password.
- Entropy estimation and a visual password-strength indicator.
- Scrollable password display for longer passwords.
- Copy generated passwords to the clipboard.

### Passphrase Generator

- Generate passphrases using 2–12 randomly selected words.
- Optional capitalization of the first letter of each word.
- Optional single random digit (0–9) appended to one randomly selected word.
- Configurable word separator, including `-`, `_`, `.`, a space, or no separator.
- Entropy estimation and a visual password-strength indicator.
- Copy generated passphrases to the clipboard.

### General

- Native KDE Plasma interface and widget integration.
- Persistent settings through KDE's KConfig system.
- Shared C++ cryptographic random number provider.
- Integrated About, configuration, and help information.

## Security and randomness

PassForge uses Qt's `QRandomGenerator::system()` through its C++ QML module, `OpenSquares.PassForge`.

This uses the operating system's cryptographically secure random number source.

### Password generation

- Character selection uses uniformly distributed random indices.
- Required numbers and special characters are generated separately to satisfy the configured minimum requirements.
- Remaining characters are selected from the enabled character sets.
- A Fisher–Yates shuffle randomizes the final character positions.

### Passphrase generation

- The bundled word list contains 7,776 words.
- Each word is selected independently using a uniformly distributed random index.
- When enabled, one decimal digit (0–9) is appended to a randomly selected word.
- Capitalization is deterministic and does not contribute additional entropy.
- The separator is configurable but does not contribute entropy.

### Entropy estimates

PassForge provides theoretical entropy estimates to help users understand the strength of generated passwords and passphrases.

For passphrases, the estimate is based on independent word selections:

`wordCount × log₂(wordListSize)`

When numeric suffixes are enabled, the estimate additionally accounts for the random digit and its randomly selected position.

For passwords, the estimate considers the enabled character pool, password length, and configured minimum character requirements.

These figures are estimates rather than formal security guarantees. They do not constitute an independent security audit of the generator.

Keep generated passwords and passphrases private. Be aware that clipboard managers may retain copied credentials in clipboard history.

## Requirements

- KDE Plasma 6
- CMake 3.21 or newer
- C++17-compatible compiler
- Qt 6 development packages, including Core and Qml
- Plasma 6 development/runtime environment
- CMake build tools and Ninja or Make

## Build and install

Clone the repository and enter the project directory:

```bash
git clone https://github.com/aaryanvangari/passforge.git
cd passforge
```

Build and install the generated QML module into the project directory:

```bash
./build-passforge.sh
```

The build script performs the following operations:

1. Configures the CMake project.
2. Builds the C++ QML module.
3. Installs the generated plugin and QML module metadata into the project directory.

Install PassForge as a Plasma applet:

```bash
kpackagetool6 --type Plasma/Applet --install .
```

For subsequent updates:

```bash
kpackagetool6 --type Plasma/Applet --upgrade .
```

After installation, PassForge can be added to the desktop or panel through Plasma's widget browser.

## Development

The project uses CMake and Qt's QML module system to build the native C++ random number provider.

The main development workflow is:

```bash
./build-passforge.sh
```

Then install or upgrade the Plasmoid:

```bash
kpackagetool6 --type Plasma/Applet --install .
```

For subsequent updates:

```bash
kpackagetool6 --type Plasma/Applet --upgrade .
```

To test the widget in a standalone window:

```bash
plasmawindowed com.opensquares.passforge
```

## Project structure

```text
passforge/
├── CMakeLists.txt
├── metadata.json
├── build-passforge.sh
├── README.md
├── LICENSE
├── src/
│   ├── SecureRandom.h
│   └── SecureRandom.cpp
└── contents/
    ├── screenshot.png
    ├── config/
    │   ├── config.qml
    │   └── main.xml
    └── ui/
        ├── main.qml
        ├── PasswordGenerator.qml
        ├── PasswordGenerator.js
        ├── PassphraseGenerator.qml
        ├── PassphraseGenerator.js
        ├── words.js
        └── OpenSquares/
            └── PassForge/
                ├── qmldir
                ├── libpassforge.so
                ├── libpassforgeplugin.so
                └── passforge.qmltypes
```

### Components

| Component | Purpose |
|---|---|
| `metadata.json` | Plasmoid identity, metadata, author information and icon |
| `CMakeLists.txt` | C++ QML module build and installation rules |
| `src/` | C++ cryptographic random number provider |
| `contents/ui/main.qml` | Main Plasma widget interface and generator tabs |
| `contents/ui/PasswordGenerator.qml` | Password generator interface and configuration handling |
| `contents/ui/PasswordGenerator.js` | Password generation, shuffling and entropy estimation |
| `contents/ui/PassphraseGenerator.qml` | Passphrase generator interface and configuration handling |
| `contents/ui/PassphraseGenerator.js` | Passphrase generation and entropy estimation |
| `contents/ui/words.js` | Bundled 7,776-word dictionary |
| `contents/config/` | Configuration interface and settings schema |
| `contents/screenshot.png` | Widget preview displayed in Plasma's widget browser |
| `contents/ui/OpenSquares/PassForge/` | Generated C++ QML plugin and module metadata |

The QML module files are generated during the build and installation process.

## License

Copyright (c) Aaryan Vangari

PassForge is licensed under the **GNU General Public License v3.0 or later**.

See [LICENSE](./LICENSE) for the full license text.

## Support and bug reports

For bug reports, feature requests, and questions, visit the [PassForge GitHub Issues](https://github.com/aaryanvangari/passforge/issues) page.

Project website: [passforge.opensquares.in](https://passforge.opensquares.in)