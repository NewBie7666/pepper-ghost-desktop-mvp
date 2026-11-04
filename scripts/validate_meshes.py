#!/usr/bin/env python3
"""Validate six STL files. This is not a physical fit or optics test."""
from pathlib import Path
import trimesh

ROOT = Path(__file__).resolve().parents[1]
STLS = ROOT / "hardware" / "stl"
if not STLS.is_dir():
    STLS = ROOT / "build" / "stl"

EXPECTED = {
    f"bracket_{size}mm_{thickness}mm.stl"
    for size in (100, 150) for thickness in (2, 3)
} | {f"bridge_{size}mm.stl" for size in (100, 150)}
actual = {p.name for p in STLS.glob("*.stl")}
assert actual == EXPECTED, f"Unexpected STL set: missing={EXPECTED - actual}; extra={actual - EXPECTED}"
for path in sorted(STLS.glob("*.stl")):
    mesh = trimesh.load_mesh(str(path), process=True)
    assert isinstance(mesh, trimesh.Trimesh), f"Unexpected mesh: {path.name}"
    assert len(mesh.vertices) > 0 and len(mesh.faces) > 0, f"Empty mesh: {path.name}"
    assert mesh.is_watertight, f"Non-watertight mesh: {path.name}"
    assert mesh.is_winding_consistent, f"Bad face winding: {path.name}"
    print(f"PASS {path.name}: {len(mesh.faces)} faces; watertight")
print("Checked 6 STL meshes. Physical fit and optical quality remain unverified.")
