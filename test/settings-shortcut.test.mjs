import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

test('Settings → Shortcut shows DMS keybind guidance', async () => {
  const view = await readFile(new URL('../SettingsView.qml', import.meta.url), 'utf8');
  assert.match(view, /dms ipc call gentle-dot\.client openChat/);
  assert.doesNotMatch(view, /hyprctl/);
});
