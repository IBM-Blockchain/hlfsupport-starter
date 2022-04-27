#!/bin/bash

#
# SPDX-License-Identifier: Apache-2.0
#

function usage() {
    echo "Usage: pkgcc.sh -l <label> [-m <META-INF directory>]"
}

function error_exit {
    echo "${1:-"Unknown Error"}" 1>&2
    exit 1
}

while getopts "hl:a:m:" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        l)
            label=${OPTARG}
            ;;
        m)
            metainf=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

type=node

if [ -z "$label" ]; then
    usage
    exit 1
fi

metadir=$(basename "$metainf")
if [ -n "$metainf" ]; then
    if [ "META-INF" != "$metadir" ]; then
        error_exit "Invalid chaincode META-INF directory $metadir: directory name must be 'META-INF'"
    elif [ ! -d "$metainf" ]; then
        error_exit "Cannot find directory $metadir"
    fi
fi

prefix=$(basename "$0")
tempdir=$(mktemp -d -t "$prefix.XXXXXXXX") || error_exit "Error creating temporary directory"

if [ -n "$DEBUG" ]; then
    echo "label = $label"
    echo "type = $type"
    echo "file = $file"
    echo "tempdir = $tempdir"
    echo "metainf = $metainf"
fi


mkdir -p "$tempdir/src"
cp -r dist "$tempdir/src"
cp package.json "$tempdir/src"
cp npm-shrinkwrap.json "$tempdir/src"

if [ -n "$metainf" ]; then
    cp -a "$metainf" "$tempdir/src/"
fi

mkdir -p "$tempdir/pkg"
cat << METADATA-EOF > "$tempdir/pkg/metadata.json"
{
    "type": "$type",
    "label": "$label"
}
METADATA-EOF


tar -C "$tempdir" -czf "$tempdir/pkg/code.tar.gz" src 
tar -C "$tempdir/pkg" -czf "$label.tgz" metadata.json code.tar.gz
rm -Rf "$tempdir"

packageid="${label}:$(shasum -a 256 $label.tgz | cut -d ' ' -f1)"
echo ${packageid}
