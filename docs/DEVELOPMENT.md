# Development

- `main.tscn`, `project.godot`: Godot entry point and settings.
- `scripts/`: puzzle logic, rendering, ship animation, and audio.
- `assets/art/toy/`: current artwork and generation prompts.
- `assets/audio/`: active music and effects.
- `assets/promo/`: cover and prompt.
- `web/`: loading page, favicon, and export instructions.
- `tests/`: gameplay regressions and capture scripts.
- `tools/`: level auditing, music synthesis, and web export.
- `build/`, `.godot/`, `.export_templates/`, `archive/`: ignored local output, caches, and retired assets.

## Run and export

Requires Godot 4.7.2, Python 3, and a WebGL 2 browser. Put `godot` on PATH.

```sh
godot --editor --path .
sh tools/export_web.sh
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/web
```

The export script downloads the matching official single-thread Web template when missing. Serve every file in `build/web` together; opening HTML directly is unsupported. GitHub Actions builds and deploys `main` to Pages. No COOP/COEP headers are required.

## Checks

```sh
python3 tools/routes.py
godot --headless --editor --import --quit
godot --headless --script tests/motion_regression.gd
godot --headless --script tests/input_buffer.gd
godot --headless --script tests/island_map.gd
```

`tests/playthrough.gd` checks all 20 islands and persistence. Run it in CI or a disposable user-data environment: it writes completion records. Capture scripts write screenshots under `build/captures/`.

Browser progress and sound preferences use local storage, independently of desktop saves. Desktop saves retain the original Mistbound user-directory name for compatibility.
