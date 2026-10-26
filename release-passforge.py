#!/usr/bin/env python3
"""Build, verify, and archive a PassForge Debian binary package."""

from __future__ import annotations

import hashlib
import shutil
import subprocess
import sys
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent
RELEASE_DIR = PROJECT_DIR / "release"
PACKAGE_NAME = "passforge"


class ReleaseError(RuntimeError):
    """Raised when a release step fails."""


def run(command: list[str], *, cwd: Path = PROJECT_DIR, capture: bool = False) -> str:
    """Run a command and convert failures into a readable release error."""
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            check=True,
            text=True,
            stdout=subprocess.PIPE if capture else None,
            stderr=subprocess.PIPE if capture else None,
        )
    except FileNotFoundError as exc:
        raise ReleaseError(f"Required command not found: {command[0]}") from exc
    except subprocess.CalledProcessError as exc:
        details = (exc.stderr or exc.stdout or "").strip()
        message = f"Command failed (exit {exc.returncode}): {' '.join(command)}"
        if details:
            message += f"\n{details}"
        raise ReleaseError(message) from exc

    return result.stdout.strip() if capture else ""


def require_commands() -> None:
    commands = (
        "git",
        "dpkg-buildpackage",
        "dpkg-parsechangelog",
        "dpkg-architecture",
        "dpkg-deb",
        "sha256sum",
    )
    missing = [name for name in commands if shutil.which(name) is None]
    if missing:
        raise ReleaseError("Missing required commands: " + ", ".join(missing))


def get_package_metadata() -> tuple[str, str, str]:
    source = run(
        ["dpkg-parsechangelog", "--show-field", "Source"],
        capture=True,
    )
    version = run(
        ["dpkg-parsechangelog", "--show-field", "Version"],
        capture=True,
    )
    architecture = run(
        ["dpkg-architecture", "-qDEB_HOST_ARCH"],
        capture=True,
    )

    if source != PACKAGE_NAME:
        raise ReleaseError(
            f"Expected source package '{PACKAGE_NAME}', found '{source}'."
        )

    return source, version, architecture


def check_git_worktree() -> str:
    inside_worktree = run(
        ["git", "rev-parse", "--is-inside-work-tree"],
        capture=True,
    )
    if inside_worktree != "true":
        raise ReleaseError("This directory is not inside a Git working tree.")

    status = run(["git", "status", "--porcelain"], capture=True)
    if status:
        raise ReleaseError(
            "Git working tree is not clean. Commit or otherwise resolve these "
            "changes before releasing:\n" + status
        )

    commit = run(["git", "rev-parse", "--short", "HEAD"], capture=True)
    return commit


def package_control_field(package_file: Path, field: str) -> str:
    return run(
        ["dpkg-deb", "--field", str(package_file), field],
        capture=True,
    )


def verify_package(
    package_file: Path,
    expected_version: str,
    expected_architecture: str,
) -> None:
    package = package_control_field(package_file, "Package")
    version = package_control_field(package_file, "Version")
    architecture = package_control_field(package_file, "Architecture")
    depends = package_control_field(package_file, "Depends")

    if package != PACKAGE_NAME:
        raise ReleaseError(f"Unexpected binary package name: {package}")
    if version != expected_version:
        raise ReleaseError(
            f"Package version mismatch: expected {expected_version}, got {version}"
        )
    if architecture not in (expected_architecture, "all"):
        raise ReleaseError(
            f"Architecture mismatch: expected {expected_architecture} or all, "
            f"got {architecture}"
        )
    if not depends:
        raise ReleaseError("Package has no Depends field.")

    contents = run(["dpkg-deb", "--contents", str(package_file)], capture=True)
    required_paths = (
        "libpassforge.so",
        "libpassforgeplugin.so",
        "/OpenSquares/PassForge/qmldir",
        "com.opensquares.passforge/metadata.json",
        "com.opensquares.passforge/contents/config/config.qml",
        "com.opensquares.passforge/contents/config/main.xml",
        "com.opensquares.passforge/contents/ui/main.qml",
    )
    missing = [path for path in required_paths if path not in contents]
    if missing:
        raise ReleaseError(
            "Package is missing expected files:\n  " + "\n  ".join(missing)
        )

    print("Package verification:")
    print(f"  Package:      {package}")
    print(f"  Version:      {version}")
    print(f"  Architecture: {architecture}")
    print(f"  Depends:      {depends}")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as package:
        for chunk in iter(lambda: package.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    print("PassForge Debian release")
    print(f"Repository: {PROJECT_DIR}")

    require_commands()

    commit = check_git_worktree()
    package, version, architecture = get_package_metadata()
    filename = f"{package}_{version}_{architecture}.deb"
    build_output = PROJECT_DIR.parent / filename
    release_package = RELEASE_DIR / filename

    print(f"Git commit: {commit}")
    print(f"Package:    {filename}")

    if release_package.exists():
        raise ReleaseError(
            f"Release already exists: {release_package}\n"
            "Refusing to overwrite a previously archived package."
        )

    if build_output.exists():
        raise ReleaseError(
            f"Build output already exists: {build_output}\n"
            "Move or remove it before starting a new release."
        )

    print("\nCleaning previous Debian build artifacts...")
    run(["debian/rules", "clean"])

    print("\nBuilding binary package...")
    run(["dpkg-buildpackage", "-us", "-uc", "-b"])

    if not build_output.is_file():
        raise ReleaseError(f"Expected build output was not created: {build_output}")

    print("\nVerifying generated package...")
    verify_package(build_output, version, architecture)

    RELEASE_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copy2(build_output, release_package)

    checksum = sha256_file(release_package)
    checksum_file = release_package.with_suffix(release_package.suffix + ".sha256")
    checksum_file.write_text(f"{checksum}  {release_package.name}\n", encoding="utf-8")

    print("\nRelease completed successfully.")
    print(f"  Package:  {release_package}")
    print(f"  SHA-256:  {checksum_file}")
    print(f"  Checksum: {checksum}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ReleaseError as error:
        print(f"\nERROR: {error}", file=sys.stderr)
        raise SystemExit(1)
