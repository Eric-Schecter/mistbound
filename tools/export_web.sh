#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p build/web
touch build/.gdignore
# Clear only generated files so old export assets cannot leak into the package.
python3 - <<'CLEAN'
from pathlib import Path
for path in Path('build/web').iterdir():
    if path.is_file(): path.unlink()
CLEAN
if [ ! -f .export_templates/web_nothreads_release.zip ]; then
  python3 tools/fetch_web_template.py
fi
godot --headless --editor --path . --import --quit
godot --headless --path . --export-release Web build/web/index.html
cp web/README.txt build/web/README.txt
cp web/favicon.svg build/web/favicon.svg
touch build/web/.nojekyll
cp assets/promo/mistbound-cover.png build/web/cover.png
python3 - <<'PY'
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
with ZipFile('build/mistbound-web.zip', 'w', ZIP_DEFLATED) as archive:
    for path in sorted(Path('build/web').iterdir()):
        if path.is_file(): archive.write(path, path.name)
print('Ready: build/web/index.html and build/mistbound-web.zip')
PY
