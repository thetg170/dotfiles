import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const [directory, session] = process.argv.slice(2);
const tmux = (...args) => execFileSync("tmux", [
  ...(process.env.DOTFILES_TMUX_SOCKET ? ["-S", process.env.DOTFILES_TMUX_SOCKET] : []), ...args,
], { encoding: "utf8" }).trim();
const tick = () => {
  for (const file of fs.readdirSync(directory).filter((name) => name.endsWith(".request"))) {
    const requestPath = path.join(directory, file);
    let response;
    try {
      const request = JSON.parse(fs.readFileSync(requestPath, "utf8"));
      if (request.action === "reference") {
        if (typeof request.text !== "string" || request.text.length > 8192 || /[\r\n\x00-\x1f]/.test(request.text)) {
          throw new Error("Invalid file reference");
        }
        const pane = tmux("show-options", "-qv", "-t", session, "@dotfiles_agent_pane");
        if (!/^%\d+$/.test(pane)) throw new Error("Agent pane is unavailable");
        tmux("send-keys", "-t", pane, "-l", "--", request.text + " ");
        tmux("select-window", "-t", pane);
        tmux("select-pane", "-t", pane);
        response = { ok: true };
      } else if (request.action === "copy") {
        execFileSync("pbcopy", [], { input: request.text, timeout: 2000 });
        response = { ok: true };
      } else if (request.action === "paste") {
        response = { ok: true, text: execFileSync("pbpaste", [], { encoding: "utf8", timeout: 2000 }) };
      } else throw new Error("Unknown bridge action");
    } catch (error) {
      response = { ok: false, error: error.message };
    }
    const target = requestPath.replace(/\.request$/, ".response");
    fs.writeFileSync(target + ".tmp", JSON.stringify(response), { mode: 0o666 });
    fs.renameSync(target + ".tmp", target);
    fs.unlinkSync(requestPath);
  }
};
setInterval(tick, 50);
