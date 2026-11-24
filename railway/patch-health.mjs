// Build-time patch: exempt the health probes from Doca's Host check. Fails the build if
// upstream changes the code, so a version bump can't silently ship without it.
import { readFileSync, writeFileSync } from "node:fs";
const file = process.argv[2];
const src = readFileSync(file, "utf8");
const needle = `    if (
      req.raw.rawHeaders
        .filter((_, i) => i % 2 === 0)
        .filter((h) => h.toLowerCase() === "host").length !== 1 ||`;
const count = src.split(needle).length - 1;
if (count !== 1) {
  console.error(`patch-health: expected the Host check once in ${file}, found ${count}`);
  process.exit(1);
}
const patched = src.replace(
  needle,
  `    if (
      !["/health", "/live", "/ready"].includes(req.url.split("?")[0]!) &&
      (req.raw.rawHeaders
        .filter((_, i) => i % 2 === 0)
        .filter((h) => h.toLowerCase() === "host").length !== 1 ||`,
);
// Close the extra parenthesis after the second condition.
const tail = `      req.headers.host?.toLowerCase() !== origin.host.toLowerCase()
    )
      fail(421,`;
if (patched.split(tail).length - 1 !== 1) {
  console.error("patch-health: Host comparison not found");
  process.exit(1);
}
writeFileSync(
  file,
  patched.replace(
    tail,
    `      req.headers.host?.toLowerCase() !== origin.host.toLowerCase())
    )
      fail(421,`,
  ),
);
console.log("patch-health: health probes exempt from the Host check");
