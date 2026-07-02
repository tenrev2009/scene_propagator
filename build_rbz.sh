#!/usr/bin/env bash
# Builds the distributable .rbz package for Scene Propagator.
#
# A .rbz is just a zip archive containing the plugin loader file
# (scene_propagator.rb) and its support folder (ScenePropagator/) at
# the root of the archive, renamed with a .rbz extension so SketchUp's
# Extension Manager recognizes it.
#
# Usage: ./build_rbz.sh [output_dir]

set -euo pipefail

cd "$(dirname "$0")"

VERSION=$(ruby -e "require './scene_propagator'; puts ScenePropagator::PLUGIN_VERSION" 2>/dev/null \
  || grep -m1 "PLUGIN_VERSION" scene_propagator.rb | sed -E "s/.*'([0-9.]+)'.*/\1/")

OUT_DIR="${1:-dist}"
OUT_FILE="$OUT_DIR/scene_propagator-${VERSION}.rbz"

mkdir -p "$OUT_DIR"
rm -f "$OUT_FILE"

zip -rq "$OUT_FILE" \
  scene_propagator.rb \
  ScenePropagator \
  licence \
  -x '*.DS_Store'

echo "Built $OUT_FILE"
