#!/bin/bash

# Newer hosts have only the compose plugin
if command -v docker-compose >/dev/null; then dc=docker-compose; else dc="docker compose"; fi

$dc -f main.yml -f $1.yml down
$dc -f main.yml -f $1.yml build
$dc -f main.yml -f $1.yml up
mkdir -p release
cp output/rootfs.tar.gz release/$1-rootfs.tar.gz
mkdir -p release/assets
cp assets/all/* release/assets/
rm release/assets/assets.txt
cp output/busybox release/assets/
cp output/libdisableselinux.so release/assets/
tar -czvf release/$1-assets.tar.gz -C release/assets/ .
for f in $(ls release/assets/); do echo "$f $(date +%s -r release/assets/$f) $(md5sum release/assets/$f | awk '{ print $1 }')" >> release/$1-assets.txt; done
rm -rf release/assets
