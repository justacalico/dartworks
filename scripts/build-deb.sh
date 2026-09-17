#!/usr/bin/env bash
# Package a built Flutter Linux bundle as a .deb for Debian/Ubuntu.
# Installs to /opt/dartworks with a /usr/bin/dartworks symlink, a desktop entry
# and an icon.
#
# Usage: scripts/build-deb.sh <bundle-dir> <version> <deb-arch> <output-file>
#   deb-arch: amd64 or arm64
set -euo pipefail

BUNDLE_DIR="${1:?usage: build-deb.sh <bundle-dir> <version> <deb-arch> <output-file>}"
VERSION="${2:?usage: build-deb.sh <bundle-dir> <version> <deb-arch> <output-file>}"
ARCH="${3:?usage: build-deb.sh <bundle-dir> <version> <deb-arch> <output-file>}"
OUT="${4:?usage: build-deb.sh <bundle-dir> <version> <deb-arch> <output-file>}"

if ! command -v dpkg-deb >/dev/null 2>&1; then
  echo "build-deb: dpkg-deb not found (install the dpkg-dev package)" >&2
  exit 1
fi
if [ ! -d "$BUNDLE_DIR" ]; then
  echo "build-deb: bundle dir not found: $BUNDLE_DIR" >&2
  exit 1
fi
if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
  echo "build-deb: unsupported arch: $ARCH" >&2
  exit 1
fi

PKGDIR="$(mktemp -d)"
trap 'rm -rf "$PKGDIR"' EXIT
mkdir -p "$PKGDIR/opt/dartworks" "$PKGDIR/usr/bin" "$PKGDIR/DEBIAN" \
  "$PKGDIR/usr/share/applications" \
  "$PKGDIR/usr/share/icons/hicolor/256x256/apps"

cp -r "$BUNDLE_DIR/." "$PKGDIR/opt/dartworks/"
ln -sf /opt/dartworks/dartworks "$PKGDIR/usr/bin/dartworks"
install -m 644 "$BUNDLE_DIR/data/flutter_assets/assets/icon/icon.png" \
  "$PKGDIR/usr/share/icons/hicolor/256x256/apps/dartworks.png"

cat > "$PKGDIR/usr/share/applications/dartworks.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=DARTWORKS
Comment=2D physics demake of BONEWORKS built with Flutter
Exec=/usr/bin/dartworks
Icon=dartworks
Categories=Game;
Terminal=false
EOF

cat > "$PKGDIR/DEBIAN/control" <<EOF
Package: dartworks
Version: $VERSION
Section: games
Priority: optional
Architecture: $ARCH
Maintainer: HttpAnimations <noreply@gitlab.com>
Description: 2D physics demake of BONEWORKS in Flutter
 A fan-made 2D physics-based demake of BONEWORKS built with Flutter and
 Forge2D. Educational and entertainment purposes only.
EOF

dpkg-deb --build "$PKGDIR" "$OUT" >/dev/null
echo "build-deb: $OUT"
