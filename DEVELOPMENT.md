# PassForge — Developer Build, Release and Installation

This guide describes the workflow for developers who want to build PassForge from its source code, create a Debian package (`.deb`), install it locally, and verify that it is available as a KDE Plasma 6 widget.

## 1. Development Environment

PassForge is a KDE Plasma 6 Plasmoid built using CMake, Qt 6, and KDE Frameworks/Plasma development libraries.

### Build dependencies

Install the required development tools and libraries:

```bash
sudo apt update
sudo apt install \
    build-essential \
    cmake \
    extra-cmake-modules \
    qt6-base-dev \
    qt6-declarative-dev \
    libplasma-dev \
    debhelper \
    git
```

The Debian packaging configuration also requires `debhelper-compat` version 13.

## 2. Complete and Verify Development Changes

After making changes to the source code, build and install the development version:

```bash
./build-passforge.sh
```

The development script:

1. Determines the repository directory.
2. Configures the project using CMake.
3. Builds the application.
4. Installs the QML module into the development installation directory.

The development installation is isolated under:

```text
build/dev-install/
```

This keeps development files separate from the system-wide installation.

Check the build output for errors before proceeding.

## 3. Test the Plasmoid Using plasmoidviewer

Before creating a development installation or Debian package, developers can test the Plasmoid directly from the source directory using KDE's `plasmoidviewer`.

This is useful during QML and UI development because it allows testing local source changes without installing the widget system-wide.

### 3.1 Install plasmoidviewer

Install the Plasma development tools:

```bash
sudo apt install plasma-sdk
```

Verify that the executable is available:

```bash
plasmoidviewer --version
```

### 3.2 Launch PassForge from the source directory

From the repository root, run:

```bash
plasmoidviewer -a .
```

The `-a` option adds the Plasmoid to the viewer. The `.` specifies the current directory as the Plasmoid source.

This loads PassForge directly from the local repository, allowing developers to test their current source changes.

### 3.3 Take screenshots

```bash
plasmawindowed com.opensquares.passforge
```

This command loads the applet in a window and we can take screenshots easily using spectacle utility.

### 3.4 Test and debug

Use the viewer to check:

- Widget layout and appearance.
- Password and passphrase generation.
- Configuration options.
- Strength indicator and configurable colors.
- UI behaviour after changing settings.
- QML errors and runtime warnings.

Keep the terminal open while testing to inspect QML warnings and errors.

After modifying the source, close and relaunch `plasmoidviewer` if the changes are not reflected automatically.

### 3.5 Development testing versus installed testing

There are two different testing stages:

| Method | Purpose |
|---|---|
| `plasmoidviewer -a .` | Quickly test the local source during development. |
| `./build-passforge.sh` | Build and install the development QML module into the isolated development directory. |
| Debian package installation | Verify the actual packaged application in the system-wide Plasma environment. |

A successful `plasmoidviewer` test does not replace testing the final Debian package. Both are important because the installed package also depends on correct installation paths, metadata, and packaging configuration.

## 4. Prepare a Debian Release

PassForge uses Debian's binary package build workflow. The source is maintained in GitHub, so the release process builds the binary package directly from the Git working tree rather than generating Debian source packages.

### 4.1 Update the Debian changelog

Before creating a new release, update:

```text
debian/changelog
```

Add a new entry at the top with the next package version.

For example:

```text
passforge (1.0.0-5) unstable; urgency=medium

  * Describe the changes included in this release.

 -- Maintainer Name <maintainer@example.com>  Date
```

Use the appropriate version and release notes for the changes being published.

Debian package versions follow this general format:

```text
upstream-version-debian-revision
```

For example, `1.0.0-5` represents upstream version `1.0.0`, Debian revision `5`.

### 4.2 Review and commit changes

The release script requires a clean Git working tree. This ensures that the package corresponds to a committed state of the repository.

Review the changes:

```bash
git status
git diff
```

Stage and commit the completed work:

```bash
git add .
git commit -m "Prepare PassForge 1.0.0-5 release"
```

Verify that the working tree is clean:

```bash
git status
```

There should be no uncommitted changes.

## 5. Build the Debian Package

Run the release script from the repository root:

```bash
./release-passforge.py
```

The script automates the release process.

### Release script workflow

1. Checks that the required build commands are available.
2. Verifies that the repository is a Git working tree.
3. Ensures that there are no uncommitted changes.
4. Reads the package name, version, and architecture from Debian metadata.
5. Checks for existing build output and archived release files to prevent accidental overwrites.
6. Cleans previous Debian build artifacts.
7. Builds the binary package using:

   ```bash
   dpkg-buildpackage -us -uc -b
   ```

8. Verifies the generated package metadata:
   - Package name
   - Version
   - Architecture
   - Dependencies
9. Checks that important PassForge files are included in the package.
10. Calculates the SHA-256 checksum.
11. Archives the package and checksum in the release directory.

The script does not automatically install the package or modify the system.

### Release output

The resulting files are stored in:

```text
release/
├── passforge_1.0.0-5_amd64.deb
└── passforge_1.0.0-5_amd64.deb.sha256
```

The original build output is also retained in the parent directory of the repository.

The `release/` directory is ignored by Git because it contains generated release artifacts.

### Important release safeguards

The release script intentionally refuses to:

- Build from a Git working tree containing uncommitted changes.
- Overwrite an existing build output.
- Overwrite an existing archived `.deb`.
- Overwrite an existing checksum file.

Each new release must therefore use a new Debian package version in `debian/changelog`.

## 6. Verify the Generated Package

Before installing, verify the SHA-256 checksum:

```bash
cd release
sha256sum --check passforge_1.0.0-5_amd64.deb.sha256
```

Expected output:

```text
passforge_1.0.0-5_amd64.deb: OK
```

Inspect the package metadata:

```bash
dpkg-deb --info passforge_1.0.0-5_amd64.deb
```

Inspect the packaged files:

```bash
dpkg-deb --contents passforge_1.0.0-5_amd64.deb
```

The package should contain the PassForge QML module and the Plasma Plasmoid files.

## 7. Install PassForge

Install the generated Debian package using APT:

```bash
sudo apt install ./passforge_1.0.0-5_amd64.deb
```

APT resolves and installs the package dependencies.

To verify the installed package:

```bash
dpkg -l passforge
```

To inspect the files installed by the package:

```bash
dpkg -L passforge
```

## 8. Find PassForge in KDE Plasma

Once installed, PassForge should be available as a Plasma 6 widget.

To add it to the desktop:

1. Right-click an empty area of the KDE Plasma desktop.
2. Select **Enter Edit Mode**.
3. Open **Add Widgets**.
4. Search for `PassForge`.
5. Drag the PassForge widget onto the desktop.

The widget is identified internally by:

```text
com.opensquares.passforge
```

Its package metadata is installed under the Plasma Plasmoids directory, while its QML module is installed under the Qt 6 QML module directory.

### If PassForge does not appear

Plasma may need to reload its widget metadata after installation.

First, close and reopen the Add Widgets panel. If the widget still does not appear, restart the Plasma session or log out and log back in.

```bash
# Restart plasma session
systemctl --user restart plasma-plasmashell
```

## 9. Upgrade an Existing Installation

When releasing a newer version, update `debian/changelog`, commit the changes, and run the release script again.

Install the newly generated package:

```bash
sudo apt install ./release/passforge_1.0.0-6_amd64.deb
```

APT upgrades the installed package when the new version is higher.

## 10. Uninstall PassForge

To remove PassForge while retaining package configuration files:

```bash
sudo apt remove passforge
```

To remove the package and its configuration files:

```bash
sudo apt purge passforge
```

## 11. Project Release Checklist

Before publishing a new Debian release, verify the following:

- [ ] Development build completes successfully.
- [ ] Changes have been tested in KDE Plasma.
- [ ] `debian/changelog` contains the new version and release notes.
- [ ] All intended changes are committed to Git.
- [ ] Git working tree is clean.
- [ ] Release script completes successfully.
- [ ] Generated `.deb` passes package verification.
- [ ] SHA-256 checksum verification reports `OK`.
- [ ] Package installs successfully.
- [ ] PassForge appears in KDE Plasma's Add Widgets list.
- [ ] Widget launches and works as expected.

---

## 12. Automated GitHub Releases

PassForge uses GitHub Actions to automate Debian package builds and publish releases on the repository's GitHub Releases page.

The workflow is defined in:

```text
.github/workflows/release.yml
```

It is triggered whenever a Git tag matching `v*` is pushed.

### Release requirements

Before creating an official release:

1. Complete development and test the Plasmoid locally using `plasmoidviewer`.
2. Run the development build and verify the development installation.
3. Update `debian/changelog` with the new version and release notes.
4. Commit all intended changes.
5. Ensure the Git working tree is clean.
6. Push the release commit to `main`.

The Debian changelog version must match the Git tag, excluding the leading `v`.

For example:

| Debian changelog version | Git tag |
|---|---|
| `1.0.0-5` | `v1.0.0-5` |

### Triggering an official release

After pushing the release commit to `main`, create and push the corresponding Git tag:

```bash
git tag v1.0.0-5
git push origin v1.0.0-5
```

Pushing the tag triggers the GitHub Actions workflow.

### What the workflow does

The workflow:

1. Checks out the tagged source.
2. Sets up an Ubuntu 26.04 build environment.
3. Installs the required build dependencies.
4. Verifies that the Git tag matches `debian/changelog`.
5. Runs `release-passforge.py` to build the Debian package.
6. Verifies the generated SHA-256 checksum.
7. Creates a GitHub Release.
8. Uploads the `.deb` package and `.sha256` checksum as release assets.

The published GitHub Release becomes the official distribution point for the Debian package.

### Testing the release workflow

The workflow can also publish test releases without using an official release version.

Use a Debian version with a `~test` suffix:

```text
1.0.0-5~test1
```

For Git compatibility, use `-test` in the tag:

```bash
git tag v1.0.0-5-test1
git push origin v1.0.0-5-test1
```

The workflow converts `-test` to `~test` when checking the Debian changelog version and marks the resulting GitHub Release as a prerelease.

Test releases should be created from a temporary branch. Do not put test versions in the official `main` branch changelog.

### Important notes

- Always push the release commit before pushing its tag.
- The tag must point to the exact commit intended for release.
- Do not reuse an existing release tag.
- A failed workflow must be resolved before considering the release published.
- GitHub Actions uses the automatically provided `GITHUB_TOKEN`; no personal access token is required.
- The local `release-passforge.py` script remains available for manual package builds and releases.

---

## 13. Versioning and Release Numbers

PassForge follows **Semantic Versioning (SemVer)** for its application version. The version format is:

`MAJOR.MINOR.PATCH`

Each component has a specific purpose:

| Component | Increment when |
|---|---|
| MAJOR | Making incompatible changes that break existing behaviour or compatibility. |
| MINOR | Adding new functionality in a backward-compatible manner. |
| PATCH | Fixing bugs or making backward-compatible corrections. |

### 13.1 Choosing the Application Version

Use the following guidelines when deciding the next application version:

- **PATCH:** Bug fixes, minor corrections, and other backward-compatible improvements.
  - Example: `1.0.0` → `1.0.1`
- **MINOR:** New features that preserve compatibility with existing functionality.
  - Example: `1.0.0` → `1.1.0`
- **MAJOR:** Changes that introduce breaking behaviour or incompatible changes.
  - Example: `1.0.0` → `2.0.0`

Do not increment version components arbitrarily. Choose the increment based on the changes included in the release.

### 13.2 Debian Package Revision

The Debian package version consists of the upstream application version followed by a Debian revision:

`UPSTREAM_VERSION-DEBIAN_REVISION`

For example:

`1.0.0-5`

Here:
- `1.0.0` is the PassForge application version.
- `5` is the Debian packaging revision.

The Debian revision is incremented when publishing another Debian package for the same upstream application version, typically for packaging-related changes.

When the upstream application version changes, the Debian revision normally starts again at `1`.

Examples:

| Debian package version | Meaning |
|---|---|
| `1.0.0-5` | Current release: application version `1.0.0`, Debian revision `5`. |
| `1.0.0-6` | Another Debian package revision of application version `1.0.0`. |
| `1.0.1-1` | First Debian package of application version `1.0.1`. |
| `1.1.0-1` | First Debian package of application version `1.1.0`. |
| `2.0.0-1` | First Debian package of application version `2.0.0`. |

A code change does not automatically require a Debian revision increment. If the change is released as a new application version, choose the appropriate Semantic Versioning increment instead.

### 13.3 Release Version and Git Tag

The Debian changelog version is the source of truth for the package version.

For official releases, the Git tag must match the complete Debian package version, prefixed with `v`.

Examples:

| Debian changelog version | Git release tag |
|---|---|
| `1.0.0-5` | `v1.0.0-5` |
| `1.0.1-1` | `v1.0.1-1` |
| `1.1.0-1` | `v1.1.0-1` |
| `2.0.0-1` | `v2.0.0-1` |

Always update the Debian changelog version before creating and pushing the corresponding release tag. Refer to [Section 12 — Automated GitHub Releases](#12-automated-github-releases) for the release procedure.

---

**Release principle:** The Git repository is the source of truth. A Debian release is built from a clean, committed state, verified, and archived with its checksum. The resulting `.deb` can then be installed independently of the development environment.