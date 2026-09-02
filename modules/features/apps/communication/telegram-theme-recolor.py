#!/usr/bin/env python3
"""Recolor a Telegram Desktop colors.tdesktop-theme file onto a base16 palette.

Strategy: classify each literal hex color by lightness/saturation, then
remap it onto the base16 scheme while preserving its original lightness
(so hover/active/selected state gradients stay intelligible):

  - low saturation (<15%)            -> interpolate across ALL 8 base16
                                         neutrals (base00..base07) by lightness
  - lightness < 30%                  -> interpolate across dark neutrals
                                         (base00..base03) by lightness
  - lightness > 65% and low-ish sat   -> interpolate across light neutrals
                                         (base05..base07) by lightness
  - else (mid-lightness, saturated,
    or bright+vivid like links)      -> snap hue to nearest base16 accent
                                         (base08..base0F), keep original
                                         lightness, use the accent's hue/sat

Alpha channel (8-digit hex) is preserved verbatim. Lines whose value is a
bare key reference (no '#') are left untouched.
"""
import colorsys
import json
import re
import sys

BASE16 = json.loads(sys.argv[1])  # {"base00": "#282828", ...}
SRC = sys.argv[2]
DST = sys.argv[3]

def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) / 255.0 for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return "".join(f"{round(max(0, min(1, c)) * 255):02x}" for c in rgb)

HSL = {k: colorsys.rgb_to_hls(*hex_to_rgb(v)) for k, v in BASE16.items()}
NEUTRALS = ["base00", "base01", "base02", "base03", "base04", "base05", "base06", "base07"]
DARK_NEUTRALS = ["base00", "base01", "base02", "base03"]
LIGHT_NEUTRALS = ["base05", "base06", "base07"]
ACCENTS = {
    "base08": (0, 15),     # red
    "base09": (15, 45),    # orange
    "base0A": (45, 70),    # yellow
    "base0B": (70, 160),   # green
    "base0C": (160, 200),  # cyan/aqua
    "base0D": (200, 260),  # blue
    "base0E": (260, 345),  # purple/pink
}

def nearest_accent(hue_deg):
    for name, (lo, hi) in ACCENTS.items():
        if lo <= hue_deg < hi:
            return name
    return "base08"  # wrap-around red (345-360)

def interpolate(stops, lightness):
    # stops sorted by their own lightness; find the bracketing pair and lerp hue+sat
    pts = sorted(((HSL[s][1], HSL[s][0], HSL[s][2]) for s in stops))  # (L, H, S)
    if lightness <= pts[0][0]:
        return pts[0][1], pts[0][2], pts[0][0]
    if lightness >= pts[-1][0]:
        return pts[-1][1], pts[-1][2], pts[-1][0]
    for (l0, h0, s0), (l1, h1, s1) in zip(pts, pts[1:]):
        if l0 <= lightness <= l1:
            t = 0 if l1 == l0 else (lightness - l0) / (l1 - l0)
            return h0 + (h1 - h0) * t, s0 + (s1 - s0) * t, lightness
    return pts[-1][1], pts[-1][2], pts[-1][0]

def recolor_hex(hexval):
    alpha = ""
    core = hexval
    if len(hexval) == 8:
        core, alpha = hexval[:6], hexval[6:]
    r, g, b = hex_to_rgb(core)
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    if s < 0.15:
        h2, s2, l2 = interpolate(NEUTRALS, l)
    elif l < 0.30:
        h2, s2, l2 = interpolate(DARK_NEUTRALS, l)
    elif l > 0.65 and s < 0.35:
        # pale/washed-out light colors only -- vivid bright colors (links,
        # "online" indicators) must still fall through to the accent branch
        # below even at high lightness, or they'd flatten into near-white
        h2, s2, l2 = interpolate(LIGHT_NEUTRALS, l)
    else:
        acc = nearest_accent(h * 360)
        ah, al, as_ = HSL[acc]
        h2, s2, l2 = ah, as_, l  # keep original lightness, accent's hue+sat

    out_r, out_g, out_b = colorsys.hls_to_rgb(h2, l2, s2)
    return "#" + rgb_to_hex((out_r, out_g, out_b)) + alpha

LINE_RE = re.compile(r"^(?P<key>[A-Za-z0-9]+):\s*#(?P<hex>[0-9a-fA-F]{6}|[0-9a-fA-F]{8});(?P<rest>.*)$")

out_lines = []
with open(SRC, encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\n")
        m = LINE_RE.match(line)
        if not m:
            out_lines.append(line)
            continue
        new_hex = recolor_hex(m.group("hex"))
        out_lines.append(f"{m.group('key')}: {new_hex};{m.group('rest')}")

with open(DST, "w", encoding="utf-8") as f:
    f.write("\n".join(out_lines) + "\n")
