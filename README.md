# V8 Prebuilt Libraries

Building V8 is slow / hard - this repository automates building monolithic V8 libraries for Linux and macOS via GitHub Actions.

See the [project releases](https://github.com/BlazerodJS/v8-prebuilt/releases) for downloads, releases are tagged with their V8 version.

## Adding New V8 Version

The `v8-versions` file lists all versions of V8 that GitHub will build. To build a new V8 version, please submit a pull request adding the version to the `v8-versions` list.
