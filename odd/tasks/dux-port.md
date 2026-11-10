# Dux port of gentle-dot

Objective: port the Omarchy plugin `omarchy-gentle-dot` (Gentle Dot chat panel + daemon) to Dux (duxlabs-dev DMS 2.x) as a standalone composite plugin, in a new self-contained repo.
Branch: `main` (fresh repo, no remote). Delivery strategy: ask-on-risk. Test runner: `node --test test/*.test.mjs` (QML-harness tests need `DISPLAY=:0` and the QtTest QML module, currently missing on this machine — see L4).

## Specs

- S1 — Dual-target strategy: new self-contained repo `/home/th3g3ntl3man/Code/dux-gentle-dot`; source repo `omarchy-gentle-dot` stays untouched. User decision: "Dual-target (repo nuevo)".
- S2 — Composite `plugin.json` (id `gentle-dot`, type `composite`, daemon+widget components, DMS permissions) replacing Omarchy `manifest.json`; `package.json` renamed to `dux-gentle-dot`; dependency install documented (pnpm broken on this host → npm fallback).
- S3 — Daemon/widget wiring: Client.qml's `bar.shell.serviceFor` → daemon `PluginComponent` (import `qs.Modules.Plugins`, `pluginId` + `pluginService`); widget reaches daemon via `PluginService.pluginDaemonInstances[pluginId]`.
- S4 — Panel.qml: Omarchy `Panel` base → DMS widget pills + PopoutComponent. StickyPanel/DetachedWindow stay Quickshell Windows (quickCapture floating-components precedent).
- S5 — Settings persist via DMS pluginData (`savePluginData`/`loadPluginData`) replacing `shell.updateEntryInline`; SettingsView uses `PluginSettings` with pluginId prop.
- S6 — Theme/widget sweep: `qs.Commons`/`qs.Ui` → `qs.Common` Theme singleton (`Theme.barIconSize`/`barTextSize`) + `qs.Widgets` (StyledRect/StyledText/DIcon); FontIcon tokens mapped.
- S7 — DnD + state paths: Omarchy `~/.local/state/omarchy/notifications.json` DnD read → DMS DnD API (exact surface verified in T6); no omarchy state paths remain.
- S8 — IPC + keybind: plugin-owned Quickshell `IpcHandler`; keybind via DMS keybind running `dms ipc call <target> <fn>`; `hypr/` NOT ported; node install message reworded for Dux.
- S9 — README rewritten for Dux (symlink dev workflow, `dms ipc call plugins reload gentle-dot`, `dms ipc call plugins list`).
- S10 — Portable layer copied unchanged (`bridge/`, `avatar/`, `voice/`, `test/`, `third_party/`, `privacy.mjs`, `status.mjs`) + final symlink smoke test into `~/.config/dms/plugins/`.

## Tasks

| ID | Spec | Route | Status | Evidence |
|----|------|-------|--------|----------|
| T1 scaffold + feature doc + suite baseline + commit | S1, S10 | inline | done | commit <HASH>; suite 235 tests → 172 pass / 62 fail (58 QtTest env + 4 manifest by-design) / 1 skip |
| T2 composite plugin.json + package.json rename + Client daemon wiring | S2, S3 | inline | pending | |
| T3 Panel → widget pills + popout | S4 | inline | pending | |
| T4 SettingsView → pluginData + PluginSettings; port manifest tests | S5 | inline | pending | |
| T5 theme/widgets sweep (Commons/Ui → Common/Widgets) | S6 | inline | pending | |
| T6 DnD + state paths | S7 | inline | pending | |
| T7 IPC + keybind + node-install message | S8 | inline | pending | |
| T8 README for Dux | S9 | inline | pending | |
| T9 symlink install + plugins reload smoke test | S10 | inline | pending | |

## Log

- L1 (2026-11-10, verbatim user request): "me gustaria poder transformar este plugin de omarchy para poder usarlo como plugin de dank material shell"
- L2 (2026-11-10, verbatim corrections + decision): "dank linux no, es algo de dux"; question-tool choice: "Dual-target (repo nuevo)".
- L3 (2026-11-10): Scaffold executed: `git init -b main`; copied `assets/`, `avatar/`, `bridge/`, `test/`, `third_party/`, `voice/`, 20 root `*.qml` (incl. `Tailnet.qml`, `Voice.qml` discovered beyond initial inventory), `privacy.mjs`, `status.mjs`, `package.json`, `pnpm-lock.yaml`, `LICENSE`, `THIRD_PARTY_NOTICES.md`, `preview.png`; fresh `.gitignore`. NOT copied (Omarchy-specific): `manifest.json`, `hypr/`, `README.md`, `SUBMISSION.md`, `.atl/`, `.git`, old `.gitignore`. `package.json` name rename deferred to T2.
- L4 (2026-11-10): T1 environment + baseline findings: pnpm unusable on this host (mise shim AND `corepack pnpm` broken) → deps via `npm install --no-package-lock --omit=optional` (only `ws` installed; `sherpa-onnx-node` optional and absent — voice optional test skips by design). This opencode shell exports a broken `DISPLAY=0` (no colon); QML-harness tests must run with `DISPLAY=:0` (then Gtk/X11 works via Xwayland). Suite baseline: 235 tests → 172 pass, 62 fail, 1 skip. 58 fails = QML-harness tests die at `module "QtTest" is not installed` — PRE-EXISTING environmental (identical failures verified in the untouched source repo: `attachments.test.mjs` and `bubble.test.mjs` 10/11); this machine's qs/Qt lacks the QtTest QML module. 4 fails = `manifest.json` ENOENT — by design until T2 replaces it with `plugin.json` (those tests get ported in T2/T4). Verbatim L1/L2 prompts recovered from session memory (`mem_search_prompts` returned 0 stored prompts). Test logs kept in `/tmp/opencode/` (outside the worktree).
