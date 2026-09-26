# vd-wallpaper

A Plasma 6 wallpaper plugin that shows a different image on each virtual desktop and
switches instantly when you change desktops — no cross-fade, no blank frame.

It exists because Vallpaper (`at.lehklu.plasma.vallpaper6`) stopped working here and
Plasma's own image wallpaper always cross-fades (and on this NVIDIA setup the fade
renders only partly before snapping).

## How it works

`WallpaperItem` with one `Image` per virtual desktop, all loaded up front; only the
current desktop's is visible. The current desktop comes from `org.kde.taskmanager`'s
`VirtualDesktopInfo`, so no background script or D-Bus polling is involved. Images are
decoded at screen resolution for the crop/fit modes, so keeping all of them in memory
stays cheap.

Settings are per screen (per containment), stored in
`~/.config/plasma-org.kde.plasma.desktop-appletsrc` under
`[Containments][N][Wallpaper][local.vdwallpaper][General]`:

| Key             | Meaning                                                           |
|-----------------|-------------------------------------------------------------------|
| `DesktopImages` | list of `desktop-uuid=file:///path` entries                       |
| `FillMode`      | QtQuick `Image.FillMode` (2 = scaled and cropped, the default)    |
| `Color`         | background around the image, and for desktops without an image  |

Desktops are keyed by KWin's desktop UUID, so renaming or reordering desktops keeps
their images.

## Install

```sh
./install.sh             # install or upgrade into ~/.local/share/plasma/wallpapers
./install.sh --restart   # same, then restart plasmashell to load the new code
./install.sh --remove    # uninstall
```

Plasma caches loaded QML, so an upgrade only shows up after plasmashell restarts.

Then right-click the desktop → *Configure Desktop and Wallpaper…* → Wallpaper type
*Virtual Desktop Wallpaper*, and choose an image for each desktop. The dialog applies to
the screen you right-clicked on.

To set it from a shell instead (here: the screen Plasma numbers 1):

```sh
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var ds = desktops();
for (var i = 0; i < ds.length; i++) if (ds[i].screen == 1) {
    ds[i].wallpaperPlugin = "local.vdwallpaper";
    ds[i].currentConfigGroup = ["Wallpaper", "local.vdwallpaper", "General"];
    ds[i].writeConfig("DesktopImages", ["<desktop-uuid>=file:///path/to/image.jpg"]);
}'
```

Desktop UUIDs: `qdbus6 --literal org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.desktops`.

## Development

```
package/                  the KPackage installed by install.sh
  metadata.json
  contents/config/main.xml   config schema
  contents/ui/main.qml       Plasma entry point, a thin WallpaperItem wrapper
  contents/ui/WallpaperView.qml  the wallpaper itself
  contents/ui/config.qml     settings page
  contents/code/images.js    DesktopImages parsing/editing (unit tested)
tests/tst_images.qml      qmltestrunner tests for images.js
check.sh                  qmllint (warnings are errors) + unit tests
install.sh
```

```sh
sudo apt install qt6-declarative-dev-tools qml6-module-qttest   # once
./check.sh
```

Notes:

- `org.kde.plasma.plasmoid` (`WallpaperItem`) is provided by plasmashell at runtime and
  has no type info on disk, so `main.qml` disables the `import`, `unresolved-type` and
  `missing-property` lint categories. It is kept to a few lines for that reason; all
  logic is in `WallpaperView.qml`, which is fully linted.
- CI doesn't install `plasma-workspace` (it drags in most of a desktop) just for the
  `org.kde.taskmanager` type info; it unpacks that one directory from the .deb.
- qmllint 6.8 segfaults on `.js` files when `--max-warnings` is set, so `check.sh` lints
  those without it and fails on any output instead.
- Strings use `qsTr` rather than KDE's `i18n` (no translations, and qmllint knows `qsTr`).
- Runtime errors show up in `journalctl --user -u plasma-plasmashell | grep vdwallpaper`.

CI (`.github/workflows/check.yml`) runs shellcheck and `check.sh` in a Debian trixie
container on every push and pull request.

Tested on Plasma 6.3.6 / Qt 6.8.2 (Debian trixie).

## License

Public domain, see [UNLICENSE](UNLICENSE).
