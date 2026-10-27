import fs from "node:fs";

const [input, output] = process.argv.slice(2);
const result = fs.readFileSync(input, "utf8").trim().split("\n").reverse().flatMap((line) => {
  try { return [JSON.parse(line)]; } catch { return []; }
}).find((item) => item.outcome === "success" && item.containerId);
if (!result) throw new Error("Dev Containers did not return a successful container result.");
fs.writeFileSync(output, JSON.stringify(result), { mode: 0o600 });
