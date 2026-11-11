import { test } from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

// Panel.pushSettings hands plugin settings to the shared daemon service.
// Every expected setting must be pushed with its default fallback.
test("pushSettings forwards every expected setting with the default", async () => {
  const defaults = {
    nodePath: "node",
    serverUrl: "ws://127.0.0.1:4317/ws",
    tokenFile: "~/.gentle-dot/token",
    voiceSendOnStop: false,
    notifications: true,
    notificationSound: true,
    panelOpacity: 0.95,
    avatarSleepMinutes: 30,
  };
  const panel = await readFile(new URL("../Panel.qml", import.meta.url), "utf8");
  const body = panel.match(/function pushSettings\(\) \{[\s\S]*?client\.configure\(\{([\s\S]*?)\}\)/)[1];
  const pushed = Object.fromEntries(
    [...body.matchAll(/(\w+):\s*setting\("(\w+)",\s*([^)]+)\)/g)].map(([, key, name, fallback]) => {
      assert.equal(key, name, `${key} reads setting("${name}")`);
      return [key, JSON.parse(fallback.trim().replace(/'/g, '"'))];
    }),
  );
  assert.deepEqual(Object.keys(pushed).sort(), Object.keys(defaults).sort());
  for (const [key, value] of Object.entries(defaults)) assert.deepEqual(pushed[key], value, `default of ${key}`);
});
