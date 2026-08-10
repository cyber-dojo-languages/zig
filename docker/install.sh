#!/bin/sh -eu

# Installs the official Zig release tarball from ziglang.org.
# The linux tarballs are statically linked against musl, so they
# run on Alpine as-is. The lib/ tree must stay next to the zig
# binary or the standard library will not resolve.

readonly ZIG_VERSION=0.16.0

case "$(uname -m)" in
  x86_64)
    readonly ARCH=x86_64
    readonly SHA256=70e49664a74374b48b51e6f3fdfbf437f6395d42509050588bd49abe52ba3d00
    ;;
  aarch64)
    readonly ARCH=aarch64
    readonly SHA256=ea4b09bfb22ec6f6c6ceac57ab63efb6b46e17ab08d21f69f3a48b38e1534f17
    ;;
  *)
    echo "Unsupported architecture $(uname -m)" >&2
    exit 1
    ;;
esac

readonly TARBALL="zig-${ARCH}-linux-${ZIG_VERSION}.tar.xz"
readonly URL="https://ziglang.org/download/${ZIG_VERSION}/${TARBALL}"

apk add --no-cache xz

wget -O "/tmp/${TARBALL}" "${URL}"
echo "${SHA256}  /tmp/${TARBALL}" | sha256sum --check --status

mkdir --parents /usr/local/lib
tar --extract --xz --file="/tmp/${TARBALL}" --directory=/usr/local/lib
mv "/usr/local/lib/zig-${ARCH}-linux-${ZIG_VERSION}" /usr/local/lib/zig
ln --symbolic /usr/local/lib/zig/zig /usr/local/bin/zig

rm "/tmp/${TARBALL}"
apk del xz
