import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const read = (name) => readFile(new URL(`../${name}`, import.meta.url), 'utf8');

// The plugin id must be consistent across DMS plugin metadata and QML wiring,
// or daemon/widget lookup and IPC silently stop working.
test('plugin id is gentle-dot everywhere the shell or a script addresses it', async () => {
  const id = JSON.parse(await read('plugin.json')).id;
  assert.equal(id, 'gentle-dot');
  const client = await read('Client.qml');
  const panel = await read('Panel.qml');
  assert.match(client, /\bpluginId:\s*"gentle-dot"/);
  assert.match(client, /target:\s*"gentle-dot\.client"/);
  assert.match(panel, /\bpluginId:\s*"gentle-dot"/);
  assert.match(panel, /PluginService\.pluginDaemonInstances\[pluginId\]|PluginService\.pluginDaemonInstances\["gentle-dot"\]/);
  assert.match(panel, /horizontalBarPill/);
  assert.match(panel, /popoutContent/);
  for (const name of ['Client.qml', 'Panel.qml', 'StickyPanel.qml', 'plugin.json'])
    assert.doesNotMatch(await read(name), /omarchy-gentle-dot/, name);
});
