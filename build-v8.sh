#!/bin/bash
set -euo pipefail

PATH="$PWD/depot_tools:$PATH"

platform=$1
version=${2#"v"}

spec=`cat <<EOF
solutions = [{
  'name': 'v8',
  'url': 'https://chromium.googlesource.com/v8/v8.git',
  'deps_file': 'DEPS',
  'managed': False,
  'custom_deps': {
    'v8/test/benchmarks/data': None,
    'v8/test/mozilla/data': None,
    'v8/test/test262/data': None,
    'v8/test/test262/harness': None,
    'v8/test/wasm-js': None,
    'v8/testing/gmock': None,
    'v8/third_party/android_tools': None,
    'v8/third_party/catapult': None,
    'v8/third_party/colorama/src': None,
    'v8/third_party/instrumented_libraries': None,
    'v8/tools/gyp': None,
    'v8/tools/luci-go': None,
    'v8/tools/swarming_client': None
  },
  'custom_vars': {
    'build_for_node': True
  }
}]
EOF
`
spec="${spec//$'\n'/}"

build_args=`cat <<EOF
  clang_use_chrome_plugins=false
  is_component_build=false
  is_debug=false
  linux_use_bundled_binutils=false
  strip_debug_info=true
  symbol_level=0
  treat_warnings_as_errors=false
  use_custom_libcxx=false
  use_sysroot=false
  v8_enable_gdbjit=false
  v8_enable_i18n_support=false
  v8_enable_test_features=false
  v8_extra_library_files=[]
  v8_monolithic=true
  v8_untrusted_code_mitigations=false
  v8_use_external_startup_data=false
  v8_use_snapshot=true
EOF
`
build_args="${build_args//$'\n'/}"

# Resolve platform name
case $platform in
  Linux)
    platform=linux
    ;;
  macOS)
    platform=darwin
    ;;
  *)
    echo "Invalid platform $platform"
    exit 1
    ;;
esac

# Acquire V8 source
if [ ! -d v8 ]; then
  fetch v8
fi

# Prepare build directory
rm -rf build
mkdir build

# Prepare solution
gclient sync -R -D --revision $version --spec "$spec"

# Generate build config
cd v8
gn gen ../build --args="$build_args"
cd ..

# Build V8
cd v8
ninja -v -C ../build v8_monolith
cd ..

# Create package
rm -rf package
mkdir package
cp build/obj/libv8_monolith.a package/libv8.a
cp -r v8/include package/include
tar czf build/v8-v$version-$platform.tar.gz -C package .

# Output package metadata for GitHub actions
echo "::set-output name=package::v8-v$version-$platform"
echo "::set-output name=package_path::build/v8-v$version-$platform.tar.gz"
