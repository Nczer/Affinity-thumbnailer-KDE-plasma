#!/bin/bash
# Install Affinity thumbnailer for KDE Plasma / freedesktop
# Supports: .afpub, .afdesign, .afphoto, .af, .afpackage

set -euo pipefail

SCRIPT_NAME="affinity-thumbnailer"
THUMBNALER_NAME="affinity.thumbnailer"
MIME_PKG_NAME="application-affinity.xml"

LOCAL_BIN="$HOME/.local/bin"
LOCAL_THUMBNAILERS="$HOME/.local/share/thumbnailers"
LOCAL_MIME_PKGS="$HOME/.local/share/mime/packages"
LOCAL_MIME_DB="$HOME/.local/share/mime"

# Create directories
mkdir -p "$LOCAL_BIN" "$LOCAL_THUMBNAILERS" "$LOCAL_MIME_PKGS"

# Install thumbnailer script
cat > "$LOCAL_BIN/$SCRIPT_NAME" << 'THUMBNALER'
#!/usr/bin/env python3
"""Extract embedded PNG thumbnails from Affinity files (.afpub, .afdesign, .afphoto, .af, .afpackage)."""

import argparse
import os
import sys

PNG_SIGNATURE = b"\x89PNG"
PNG_IEND = b"IEND"
SUPPORTED_EXTENSIONS = {".afpub", ".afdesign", ".afphoto", ".af", ".afpackage"}


def find_png(data: bytes) -> bytes | None:
    """Find and extract the first complete PNG from binary data."""
    sig_offset = data.find(PNG_SIGNATURE)
    if sig_offset == -1:
        return None

    iend_offset = data.find(PNG_IEND, sig_offset)
    if iend_offset == -1:
        return None

    png_end = iend_offset + len(PNG_IEND) + 4
    return data[sig_offset:png_end]


def extract_thumbnail(filepath: str) -> bytes | None:
    """Read a file and extract its embedded PNG thumbnail."""
    ext = os.path.splitext(filepath)[1].lower()
    if ext not in SUPPORTED_EXTENSIONS:
        print(
            f"Error: unsupported extension '{ext}'. "
            f"Supported: {', '.join(sorted(SUPPORTED_EXTENSIONS))}",
            file=sys.stderr,
        )
        return None

    if not os.path.isfile(filepath):
        print(f"Error: file not found: {filepath}", file=sys.stderr)
        return None

    with open(filepath, "rb") as f:
        data = f.read()

    return find_png(data)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extract embedded PNG thumbnail from Affinity files."
    )
    parser.add_argument("input", help="Input Affinity file (.afpub, .afdesign, .afphoto, .af, .afpackage)")
    parser.add_argument(
        "output",
        nargs="?",
        default=None,
        help="Output PNG file (default: stdout)",
    )
    args = parser.parse_args()

    png_data = extract_thumbnail(args.input)
    if png_data is None:
        print("Error: no embedded PNG thumbnail found.", file=sys.stderr)
        sys.exit(1)

    if args.output:
        with open(args.output, "wb") as f:
            f.write(png_data)
        print(f"Thumbnail saved: {args.output} ({len(png_data)} bytes)")
    else:
        sys.stdout.buffer.write(png_data)


if __name__ == "__main__":
    main()
THUMBNALER

chmod +x "$LOCAL_BIN/$SCRIPT_NAME"

# Install thumbnailer entry
cat > "$LOCAL_THUMBNAILERS/$THUMBNALER_NAME" << ENTRY
[Thumbnailer Entry]
TryExec=$LOCAL_BIN/$SCRIPT_NAME
Exec=$LOCAL_BIN/$SCRIPT_NAME %i %o
MimeType=application/affinity-publisher;application/affinity-designer;application/affinity-photo;application/affinity-v3;application/affinity-package;
ENTRY

# Install MIME types
cat > "$LOCAL_MIME_PKGS/$MIME_PKG_NAME" << 'MIMEXML'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/affinity-publisher">
    <comment>Affinity File</comment>
    <glob pattern="*.afpub"/>
  </mime-type>
  <mime-type type="application/affinity-designer">
    <comment>Affinity File</comment>
    <glob pattern="*.afdesign"/>
  </mime-type>
  <mime-type type="application/affinity-photo">
    <comment>Affinity File</comment>
    <glob pattern="*.afphoto"/>
  </mime-type>
  <mime-type type="application/affinity-v3">
    <comment>Affinity File</comment>
    <glob pattern="*.af"/>
  </mime-type>
  <mime-type type="application/affinity-package">
    <comment>Affinity File</comment>
    <glob pattern="*.afpackage"/>
  </mime-type>
</mime-info>
MIMEXML

# Update MIME database
update-mime-database "$LOCAL_MIME_DB"

echo "Affinity thumbnailer installed successfully."
echo "  Executable: $LOCAL_BIN/$SCRIPT_NAME"
echo "  Thumbnailer: $LOCAL_THUMBNAILERS/$THUMBNALER_NAME"
echo "  MIME types:  $LOCAL_MIME_PKGS/$MIME_PKG_NAME"
echo ""
echo "IMPORTANT: Enable previews in Dolphin settings:"
echo "  1. Dolphin > Settings > Configure Dolphin"
echo "  2. Interface > Previews"
echo "  3. Check 'Affinity File'"
echo "  4. Apply and restart Dolphin"
