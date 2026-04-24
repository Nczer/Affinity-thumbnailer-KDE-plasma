# Affinity-thumbnailer-KDE-plasma
Extracts embedded PNG thumbnails from Affinity files for Linux file managers.
Mostly works... I think

## Supported formats

- `.afpub` — Affinity Publisher
- `.afdesign` — Affinity Designer
- `.afphoto` — Affinity Photo
- `.af` — Affinity v3 unified format
- `.afpackage` — Affinity Package

## Requirements

- Python 3.10+
- `update-mime-database` (freedesktop MIME tools)

## Install

```bash
chmod +x install-affinity-thumbnailer.sh
./install-affinity-thumbnailer.sh
```

Installs to `~/.local/` (no sudo required):
- `~/.local/bin/affinity-thumbnailer` — executable
- `~/.local/share/thumbnailers/affinity.thumbnailer` — thumbnailer entry
- `~/.local/share/mime/packages/application-affinity.xml` — MIME types

## Enable previews in Dolphin

1. Dolphin > Settings > Configure Dolphin
2. Interface > Previews
3. Check "Affinity File"
4. Apply and restart Dolphin

## Usage

```bash
# Extract to file
affinity-thumbnailer input.afpub output.png

# Extract to stdout
affinity-thumbnailer input.afpub > output.png
```
