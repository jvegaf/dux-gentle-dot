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
dms ipc call plugins reload gentle-dot
dms ipc call plugins list
```

After code changes, reload again:

```sh
dms ipc call plugins reload gentle-dot
```

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

- This repository is a port in progress tracked in `odd/tasks/dux-port.md` (ODD task document).
- `hypr/` integration from the Omarchy plugin is not ported; use DMS keybinds instead.
