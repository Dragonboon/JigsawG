#!/usr/bin/env python3
"""Create an addon-only ZIP and checksum from a clean tracked checkout."""
import hashlib
from pathlib import Path
import subprocess
import zipfile
import argparse

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--allow-dirty', action='store_true')
    args = parser.parse_args()
    status = subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)
    if status and not args.allow_dirty:
        raise SystemExit('Commit changes first, or use --allow-dirty for local validation.')
    version = next(line.split('=', 1)[1].strip('"') for line in
                   (ROOT/'addons/jigsawg/plugin.cfg').read_text().splitlines()
                   if line.startswith('version='))
    files = subprocess.check_output(['git', 'ls-files', '-z', 'addons/jigsawg'], cwd=ROOT).decode().split('\0')
    output = ROOT/'dist'/f'JigsawG-{version}.zip'
    output.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name in sorted(filter(None, files)):
            path = ROOT/name
            if not path.is_file() or '__pycache__' in path.parts or path.suffix == '.pyc':
                continue
            info = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, path.read_bytes())
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    output.with_suffix('.zip.sha256').write_text(f'{digest}  {output.name}\n')
    print(output)


if __name__ == '__main__':
    main()
