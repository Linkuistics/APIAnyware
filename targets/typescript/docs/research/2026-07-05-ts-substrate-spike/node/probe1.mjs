// probe1.mjs — generated-style ObjC dispatch through the napi-rs addon.
//   (a) scalar/id chain: [NSString stringWithUTF8String:] -> -length
//   (b) CGRect struct-by-value return: [[NSScreen mainScreen] frame]
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const b = require("../addon.node");

let fail = 0;
const ok = (name, cond, detail = "") => {
  console.log(`${cond ? "GREEN" : "RED  "}  ${name}${detail ? "  — " + detail : ""}`);
  if (!cond) fail++;
};

// (a) scalar/id: build an NSString, ask its length.
const NSString = b.getClass("NSString");
const selWith = b.sel("stringWithUTF8String:");
const selLength = b.msgU64 ? b.sel("length") : b.sel("length");
ok("getClass(NSString) != nil", NSString !== 0n, `handle=0x${NSString.toString(16)}`);
ok("sel(stringWithUTF8String:) != nil", selWith !== 0n);

const str = b.msgIdCstr(NSString, selWith, "hello, spike");   // id
ok("stringWithUTF8String: -> id", str !== 0n, `handle=0x${str.toString(16)}`);

const len = b.msgU64(str, selLength);                          // NSUInteger
ok("-length == 12 (scalar return)", len === 12n, `got ${len}`);

// Also a class-method returning id with no args: [NSScreen mainScreen]
const NSScreen = b.getClass("NSScreen");
const mainScreen = b.msgId(NSScreen, b.sel("mainScreen"));     // id
ok("[NSScreen mainScreen] -> id", mainScreen !== 0n, `handle=0x${mainScreen.toString(16)}`);

// (b) CGRect struct-by-value: -[NSScreen frame]
const selFrame = b.sel("frame");
const r = b.msgRect(mainScreen, selFrame);
console.log(`  frame (by-value return): {x:${r.x}, y:${r.y}, w:${r.w}, h:${r.h}}`);
ok("frame w>0 && h>0 (x8 struct return crosses)", r.w > 0 && r.h > 0);

// independent cross-check via out-buffer
const p = b.rectProbe(mainScreen, selFrame);
console.log(`  frame (out-buffer probe):  [${p.map((v) => v.toFixed(1)).join(", ")}]`);
ok("out-buffer matches by-value return",
   p[0] === r.x && p[1] === r.y && p[2] === r.w && p[3] === r.h);

console.log(fail === 0 ? "\nPROBE 1: GREEN" : `\nPROBE 1: RED (${fail} failing)`);
process.exit(fail === 0 ? 0 : 1);
