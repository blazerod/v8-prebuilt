#!/usr/bin/env node

function escape(s) {
  return s
    .replace(/\r/g, "%0D")
    .replace(/\n/g, "%0A")
    .replace(/]/g, "%5D")
    .replace(/;/g, "%3B");
}

const version = process.argv[2].replace("refs/tags/", "");

const body = `Packages for V8 ${version}:

- [v8-${version}-darwin.tar.gz](https://github.com/BlazerodJS/v8-prebuilt/releases/download/${version}/v8-${version}-darwin.tar.gz)
- [v8-${version}-linux.tar.gz](https://github.com/BlazerodJS/v8-prebuilt/releases/download/${version}/v8-${version}-linux.tar.gz)

`.trim();

console.log(`::set-output name=release_body::${escape(body)}`);
