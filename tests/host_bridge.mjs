import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync, spawn } from "node:child_process";
import { setTimeout } from "node:timers/promises";

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "dotfiles-bridge-"));
const socket = path.join(scratch, "socket");
const tmux = (...args) => execFileSync("tmux", ["-S", socket, ...args], { encoding: "utf8" }).trim();
let bridge;
let serial = 0;
try {
  fs.mkdirSync(path.join(scratch, "bin"));
  fs.writeFileSync(path.join(scratch, "bin/pbcopy"), '#!/bin/sh\ncat > "$DOTFILES_TEST_CLIPBOARD"\n', { mode: 0o755 });
  fs.writeFileSync(path.join(scratch, "bin/pbpaste"), '#!/bin/sh\ncat "$DOTFILES_TEST_CLIPBOARD"\n', { mode: 0o755 });
  const pane = tmux("-f", "/dev/null", "new-session", "-d", "-P", "-F", "#{pane_id}", "-s", "bridge", "/bin/sleep 60");
  tmux("set-option", "-t", "bridge", "@dotfiles_agent_pane", pane);
  bridge = spawn("node", ["devcontainer/bridge.mjs", scratch, "bridge"], {
    env: {
      ...process.env,
      PATH: path.join(scratch, "bin") + ":" + process.env.PATH,
      DOTFILES_TMUX_SOCKET: socket,
      DOTFILES_TEST_CLIPBOARD: path.join(scratch, "clipboard"),
    },
    stdio: ["ignore", "ignore", "inherit"],
  });
  const request = async (action, text) => {
    const stem = path.join(scratch, String(++serial));
    fs.writeFileSync(stem + ".tmp", JSON.stringify({ action, text }));
    fs.renameSync(stem + ".tmp", stem + ".request");
    for (let tries = 0; tries < 100; tries++) {
      if (fs.existsSync(stem + ".response")) return JSON.parse(fs.readFileSync(stem + ".response", "utf8"));
      await setTimeout(30);
    }
    throw new Error("Bridge response timed out");
  };
  assert.equal((await request("reference", "src/a file.py:2-6")).ok, true);
  assert.match(tmux("capture-pane", "-p", "-t", pane), /src\/a file\.py:2-6/);
  assert.equal((await request("reference", "bad\ncommand")).ok, false);
  const text = "first line\nsecond line\n";
  assert.equal((await request("copy", text)).ok, true);
  assert.equal((await request("paste")).text, text);
  console.log("Host bridge tests passed: isolated tmux reference, invalid input, clipboard round-trip.");
} finally {
  if (bridge) {
    bridge.kill();
    await new Promise((resolve) => bridge.once("exit", resolve));
  }
  try { tmux("kill-server"); } catch {}
  fs.rmSync(scratch, { recursive: true, force: true });
}
