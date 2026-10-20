#!/usr/bin/env bash
# Sync the TV's apps, package the launcher and install it on the TV (run by run.sh).
set -euo pipefail
cd "$(dirname "$0")"
: "${TV_HOST:?set TV_HOST to the TV IP address}"
APP_ID=com.gathin.tvhome

python3 sync-apps.py "$TV_HOST"

rm -rf build && mkdir build
ares-package app -o build
# The launcher stays resident: close it, or relaunching it keeps running the old version's code.
ares-launch -d lgtv --close "$APP_ID" >/dev/null 2>&1 || true
ares-install -d lgtv build/${APP_ID}_*.ipk
ares-launch -d lgtv "$APP_ID"
