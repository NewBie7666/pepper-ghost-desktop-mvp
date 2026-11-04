#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/stl
for panel in 100 150; do
  for thickness in 2 3; do
    openscad -o "build/stl/bracket_${panel}mm_${thickness}mm.stl" \
      -D 'mode="print_bracket"' -D "panel_size=$panel" -D "panel_thickness=$thickness" \
      hardware/holodesk_reno3_v02.scad
  done
  openscad -o "build/stl/bridge_${panel}mm.stl" \
    -D 'mode="print_bar"' -D "panel_size=$panel" \
    hardware/holodesk_reno3_v02.scad
done
echo "Generated STLs under build/stl."
