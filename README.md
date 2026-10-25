# PassForge — KDE Plasma 6

PassForge is a KDE Plasma 6 widget for generating memorable, secure passphrases using randomly selected words. It uses Qt's system-backed cryptographic random number generator and provides a convenient interface for generating and copying passphrases.

## Features

- Generate passphrases using 1–12 randomly selected words.
- Optional capitalization of the first letter of each word.
- Optional single random digit appended to one randomly selected word.
- Configurable word separator (`-` by default), including `_`, `.`, space, or no separator.
- Entropy estimation and a visual password-strength indicator.
- Copy generated passphrases to the clipboard.
- Persistent settings through KDE's KConfig system.
- Native KDE Plasma interface and widget integration.

## Security and randomness

PassForge uses Qt's `QRandomGenerator::system()` through a small C++ QML module named `OpenSquares.PassForge`.

- Word selection uses uniformly distributed random indices.
- The bundled word list contains 7,776 words.
- When enabled, a single decimal digit (0–9) is appended to a randomly selected word.
- Capitalization is deterministic and does not contribute additional entropy.
- The separator is configurable but does not contribute entropy.

The theoretical entropy estimate is based on independent word selections:

`wordCount × log₂(wordListSize)`

When numeric suffixes are enabled, the estimate additionally accounts for the random digit and its randomly selected position.

Repeated words can introduce ambiguity in the final output, so the displayed entropy should be treated as a theoretical estimate rather than a formal security audit.

Keep generated passphrases private. Be aware that clipboard managers may retain copied passwords in clipboard history.

## Requirements

- KDE Plasma 6
- CMake 3.21 or newer
- C++17-compatible compiler
- Qt 6 development packages, including Core and Qml
- Plasma 6 development/runtime environment

## Build

Clone the repository and enter the project directory.

```bash
git clone <repository-url>
cd passforge
```

Build and install the generated QML module into the project directory:

```bash
./build-passforge.sh
```

The build script performs the following operations:

1. Configures the CMake project.
2. Builds the C++ QML module.
3. Installs the generated plugin and QML module metadata into the Plasmoid package.

## Install

Install PassForge as a Plasma applet:

```bash
kpackagetool6 --type Plasma/Applet --install .
```

For subsequent updates:

```bash
kpackagetool6 --type Plasma/Applet --upgrade .
```

You can also add PassForge to your desktop or panel through Plasma's widget browser.


## Development

For local development, build the project and install the generated QML module:

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
| `metadata.json` | Plasmoid identity, metadata and icon |
| `CMakeLists.txt` | C++ QML module build and installation rules |
| `src/` | C++ secure random number provider |
| `contents/ui/main.qml` | Main Plasma widget interface |
| `contents/ui/PassphraseGenerator.js` | Passphrase generation and entropy estimation |
| `contents/ui/words.js` | Bundled 7,776-word dictionary |
| `contents/config/` | Configuration interface and settings schema |
| `contents/screenshot.png` | Widget preview displayed in Plasma's widget browser |
| `contents/ui/OpenSquares/PassForge/` | Generated C++ QML plugin and module metadata |

## License

See the repository's license file.