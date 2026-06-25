# MacBrowser Installation & Logo Setup

## Step 1: Custom logo

Use `LOGO_PROMPT.txt` to generate a 1024×1024 PNG with transparent background.

```bash
./scripts/png-to-icns.sh MacBrowser-logo.png
# writes resources/AppIcon.icns by default
./scripts/build-app.sh
```

## Step 2: DMG installer

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
./scripts/create-dmg-background.sh
./scripts/create-dmg.sh v0.4
```

Produces `MacBrowser-v0.4.dmg`. DMG window layout requires Finder automation permission; the DMG is still created without it.

## Step 3: Publish

**Preferred (CI):**

```bash
git tag v0.4 && git push origin v0.4
```

**Local:**

```bash
./scripts/release.sh v0.4
```

`release.sh` refuses to run with uncommitted or unpushed changes.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Pillow missing | `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt` |
| Icon not visible | Ensure `resources/AppIcon.icns` exists, rebuild, `killall Finder` |
| DMG layout skipped | System Settings → Privacy → Automation → allow Terminal → Finder |
| App version shows `1.0` | Rebuild with `APP_VERSION=v0.4 ./scripts/build-app.sh` or use a tagged release |
