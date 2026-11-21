#!/usr/bin/env bash
set -e
readonly DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
readonly MIRROR=https://github.com/txn2/kubefwd/releases/download

# https://github.com/txn2/kubefwd/releases/download/1.22.3/kubefwd_checksums.txt
# https://github.com/txn2/kubefwd/releases/download/1.22.3/kubefwd_Linux_x86_64.tar.gz

dl()
{
    local lchecksum=$1
    local ver=$2
    local os=$3
    local arch=$4
    local archive_type=${5:-"tar.gz"}
    local platform="${os}_${arch}"
    local file=kubefwd_${platform}.${archive_type}
    local url=$MIRROR/${ver}/$file
    local sum
    sum=$(awk -v f="$file" '$2 == f || $2 == "*" f {print $1}' "$lchecksum")
    if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'
    then
        echo "bad or missing checksum for $file: '$sum'" >&2
        exit 1
    fi
    printf "    # %s\n" "$url"
    printf "    %s: sha256:%s\n" "$platform" "$sum"
}

dl_ver () {
    local ver=$1
    local checksum_url=${MIRROR}/${ver}/kubefwd_checksums.txt
    printf "  # %s\n" $checksum_url
    local lchecksum=$DIR/kubefwd_${ver}_checksums.txt

    curl -fsSL --proto '=https' --tlsv1.2 -o "$lchecksum" "$checksum_url"

    printf "  '%s':\n" $ver
    dl $lchecksum $ver Darwin arm64
    dl $lchecksum $ver Darwin x86_64
    dl $lchecksum $ver Linux arm64
    dl $lchecksum $ver Linux armv6
    dl $lchecksum $ver Linux i386
    dl $lchecksum $ver Linux x86_64
    dl $lchecksum $ver Windows i386 zip
    dl $lchecksum $ver Windows x86_64 zip
}

dl_ver ${1:-v1.25.18}
