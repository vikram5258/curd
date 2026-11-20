#!/bin/sh
# Installs the latest `curd` release for Linux or macOS.
#
#   curl -fsSL https://raw.githubusercontent.com/vikram5258/curd/main/install.sh | sh
#
# Options (environment variables):
#   CURD_VERSION      release to install, e.g. v0.1.2 (default: latest)
#   CURD_INSTALL_DIR  where to put the binary     (default: ~/.local/bin)
set -eu

REPO="vikram5258/curd"
INSTALL_DIR="${CURD_INSTALL_DIR:-$HOME/.local/bin}"

fail() {
    echo "error: $1" >&2
    exit 1
}

command -v curl >/dev/null 2>&1 || fail "curl is required"
command -v tar >/dev/null 2>&1 || fail "tar is required"

# Work out which prebuilt binary matches this machine.
os=$(uname -s)
arch=$(uname -m)
case "$os" in
    Linux) os_part="unknown-linux-gnu" ;;
    Darwin) os_part="apple-darwin" ;;
    *) fail "unsupported system: $os (on Windows use install.ps1)" ;;
esac
case "$arch" in
    x86_64 | amd64) arch_part="x86_64" ;;
    arm64 | aarch64) arch_part="aarch64" ;;
    *) fail "unsupported CPU: $arch" ;;
esac
target="$arch_part-$os_part"

# Find the latest release by following GitHub's /releases/latest redirect.
version="${CURD_VERSION:-}"
if [ -z "$version" ]; then
    latest_url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        "https://github.com/$REPO/releases/latest") ||
        fail "could not reach GitHub to find the latest release"
    version=${latest_url##*/}
fi
case "$version" in
    v*) ;;
    *) fail "could not work out the latest version (got '$version')" ;;
esac

name="curd-$version-$target"
url="https://github.com/$REPO/releases/download/$version/$name.tar.gz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading curd $version for $target..."
curl -fsSL "$url" -o "$tmp/curd.tar.gz" ||
    fail "no binary for $target in $version (see https://github.com/$REPO/releases)"
tar xzf "$tmp/curd.tar.gz" -C "$tmp"

mkdir -p "$INSTALL_DIR"
# Put beside the old one and then rename over it: a `curd` that is running
# (updating itself, say) cannot be written over, but can be replaced.
cp "$tmp/$name/curd" "$INSTALL_DIR/curd.new"
chmod +x "$INSTALL_DIR/curd.new"
mv -f "$INSTALL_DIR/curd.new" "$INSTALL_DIR/curd"

echo "Installed curd $version to $INSTALL_DIR/curd"
case ":$PATH:" in
    *":$INSTALL_DIR:"*) echo "Run it with: curd <file>" ;;
    *)
        echo "$INSTALL_DIR is not on your PATH. Add this line to your shell profile:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        ;;
esac
