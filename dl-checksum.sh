#!/usr/bin/env bash
set -e
readonly DIR=~/Downloads
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
    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(grep $file $lchecksum | awk '{print $1}')
}

dl_ver () {
    local ver=$1
    local checksum_url=${MIRROR}/${ver}/kubefwd_checksums.txt
    printf "  # %s\n" $checksum_url
    local lchecksum=$DIR/kubefwd_${ver}_checksums.txt

    if [ ! -e $lchecksum ];
    then
        curl -sSLf -o $lchecksum $checksum_url
    fi

    printf "  '%s':\n" $ver
    dl $lchecksum $ver Darwin arm64
    dl $lchecksum $ver Darwin x86_64
    dl $lchecksum $ver Linux arm64
    dl $lchecksum $ver Linux armv6
    dl $lchecksum $ver Linux i386
    dl $lchecksum $ver Linux x86_64
    dl $lchecksum $ver Windows armv6 zip
    dl $lchecksum $ver Windows i386 zip
    dl $lchecksum $ver Windows x86_64 zip
}

dl_ver ${1:-1.22.3}
