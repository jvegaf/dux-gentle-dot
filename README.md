# dux-gentle-dot

Native Dux/DankMaterialShell plugin for **Gentle Dot**: a chat panel daemon+widget that connects to a local or remote Gentle Dot daemon, renders conversation/activity, and supports attachments, voice dictation, and notifications.

Ported from the Omarchy plugin `omarchy-gentle-dot` to Dux (DMS 2.x composite plugin).

## Plugin

- **ID:** `gentle-dot`
- **Type:** `composite` (daemon + dankbar widget)
- **Components:** daemon `Client.qml`, widget `Panel.qml`, settings `SettingsView.qml`
- **Permissions:** `settings_read`, `settings_write`, `process`, `network`

## Requirements

- Dux/DankMaterialShell (DMS) with plugin support
- Node.js **22+** (runs the bridge and helper processes)
- `curl` (remote `/health` probe in settings)
- Optional (voice): `pw-record` (PipeWire) or `parec` (PulseAudio utils), and npm/network access for one-time speech runtime/model setup

## Install / development (symlink workflow)

From the plugin repository:

```sh
ln -sfn "$PWD" ~/.config/dms/plugins/gentle-dot

# first-time discovery (if not already known to DMS)
dms ipc call plugin-scan rescan gentle-dot
dms ipc call plugins list

# enable/reload (may also be done from DMS plugin settings)
dms ipc call plugins enable gentle-dot
dms ipc call plugins reload gentle-dot
```

After code changes to an existing file, reload again:

```sh
dms ipc call plugins reload gentle-dot
```

Adding a **new** `.qml` file to the plugin does not take effect with `plugins reload`: Qt caches the compiled
document per URL and the directory import is fixed for the life of the QML engine, so the old error keeps
reporting the old line numbers. Restart the QML process instead:

```sh
systemctl --user reload dms
```

If `plugins enable`/`reload` reports failure, check DMS/Quickshell logs for QML/plugin load errors and confirm the plugin is enabled in DMS settings. This port is under runtime validation in DMS (see development notes).

## Usage

- Add the **Gentle Dot** widget to your bar in DMS settings.
- The daemon bridge connects to the configured Gentle Dot daemon (default `ws://127.0.0.1:4317/ws`, token `~/.gentle-dot/token`).
- Open settings from the panel to configure connection, notifications, appearance, and voice.
- **Keybind (DMS):** bind `dms ipc call gentle-dot.client openChat` to open the chat.

## Settings and persistence

Settings are persisted via DMS `pluginData` (`pluginService.savePluginData` / `pluginData`). Connection, notification, appearance, and voice preferences are managed by the plugin settings UI and daemon.

## Voice (optional)

Voice dictation is private/on-device once set up. Enabling voice installs the speech runtime (`sherpa-onnx-node 2.0.1`) and downloads the Parakeet v3 model into `~/.local/share/gentle-dot/` (runtime) and the plugin model location as configured by the voice module. npm (bundled with Node.js) is required for runtime installation.

## State and cache paths

- Message times: `${XDG_STATE_HOME:-~/.local/state}/gentle-dot/message-times.json`
- Runtime cache/uploads: `${XDG_RUNTIME_DIR:-/tmp}/gentle-dot/cache/...`
- Voice runtime: `${XDG_DATA_HOME:-~/.local/share}/gentle-dot/runtime`

## Tests

```sh
# dependencies (pnpm may be unavailable on some hosts)
npm install --no-package-lock --omit=optional

# JS tests (QML harness tests require QtTest and a display)
node --test test/*.test.mjs
```

Note: on environments without the QtTest QML module or a usable display, QML harness tests will fail; non-QML tests cover bridge, status, privacy, and related logic.

## Development notes

- Port tracked in `odd/tasks/dux-port.md` (ODD task document). Tasks T1–T9 (scaffold split, DMS metadata/daemon wiring, widget/pills+popout, `pluginData` persistence, theme/widget sweep, DnD/state paths, IPC/keybind/Node messaging, README, dev symlink smoke test) are implemented on `main`.
- Runtime status (v0.1.1): the plugin loads under DMS and the widget opens. Verified on this host with
  `plugin-scan status gentle-dot` → `loaded composite`, `widget toggle gentle-dot`, and
  `gentle-dot.client openChat` / `openSettings` switching views with no QML errors in `journalctl --user -u dms`.
  Still unexercised: detach to a floating window, sticky/pinned mode, image viewer, voice dictation, and real
  focus order for `Button`/`PanelActionButton`.
- Keep the DMS plugin directory identical to this repo. On some hosts it is a **clone**, not a symlink, so a fix
  has to be copied over (or the directory replaced by the symlink above) before DMS sees it.
- `BorderSurface.qml` keeps an inert `borderSpec` property that no call site sets or reads; DMS ships no `Border`
  singleton, so nothing should start using it without a DMS-side equivalent.
- `hypr/` integration from the Omarchy plugin is not ported; use DMS keybinds/IPCs instead (e.g. `dms ipc call gentle-dot.client openChat`).
