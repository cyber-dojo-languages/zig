#!/bin/sh -eu

# Installs the newest stable Zig release from ziglang.org.
# The linux tarballs are statically linked against musl, so they
# run on Alpine as-is. The lib/ tree must stay next to the zig
# binary or the standard library will not resolve.

apk add --no-cache jq xz

readonly INDEX=/tmp/zig-index.json
wget -O "${INDEX}" https://ziglang.org/download/index.json

case "$(uname -m)" in
  x86_64)  readonly TARGET=x86_64-linux ;;
  aarch64) readonly TARGET=aarch64-linux ;;
  *)
    echo "Unsupported architecture $(uname -m)" >&2
    exit 1
    ;;
esac

# The index lists master first, which is a development build, and then the
# releases newest first. So the first key that is not master is the newest
# stable release, and the version is not written down here.
readonly ZIG_VERSION=$(jq --raw-output \
  'to_entries | map(select(.key != "master")) | .[0].key' "${INDEX}")

# The index carries the checksum beside the tarball it belongs to, so taking
# both from it keeps the download verified without naming either here.
readonly URL=$(jq --raw-output --arg v "${ZIG_VERSION}" --arg t "${TARGET}" \
  '.[$v][$t].tarball' "${INDEX}")
readonly SHA256=$(jq --raw-output --arg v "${ZIG_VERSION}" --arg t "${TARGET}" \
  '.[$v][$t].shasum' "${INDEX}")

readonly TARBALL=$(basename "${URL}")

wget -O "/tmp/${TARBALL}" "${URL}"
echo "${SHA256}  /tmp/${TARBALL}" | sha256sum --check --status

mkdir --parents /usr/local/lib
tar --extract --xz --file="/tmp/${TARBALL}" --directory=/usr/local/lib
# The tarball unpacks to a directory named after itself, so the name is taken
# from the tarball rather than rebuilt from the version and the target.
mv "/usr/local/lib/$(basename "${TARBALL}" .tar.xz)" /usr/local/lib/zig
ln --symbolic /usr/local/lib/zig/zig /usr/local/bin/zig

# Read by check_version.sh, so the gate states the version this image holds
# rather than one written down when someone last edited it.
echo "{\"zig\":\"${ZIG_VERSION}\"}" > /versions.json

rm "/tmp/${TARBALL}" "${INDEX}"
apk del jq xz
