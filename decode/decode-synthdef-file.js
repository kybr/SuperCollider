#!/usr/bin/env node

# npm install synthdef-json-decoder json-stringify-pretty-compact

const fs = require("fs");
const decoder = require("synthdef-json-decoder");
const stringify = require("json-stringify-pretty-compact");
 
const file = fs.readFileSync(process.argv[2]);
const buffer = new Uint8Array(file).buffer;
const json = decoder.decode(buffer);

console.log(stringify(json));
