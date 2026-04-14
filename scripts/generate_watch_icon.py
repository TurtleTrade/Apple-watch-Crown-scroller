#!/usr/bin/env python3
"""Generate Watch AppIcon master (1024) — book with watch dial. Requires Pillow."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

W = 1024


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    path = root / "scripts/watch-icon-source.png"
    path.parent.mkdir(parents=True, exist_ok=True)

    img = Image.new("RGBA", (W, W), (18, 28, 48, 255))
    draw = ImageDraw.Draw(img)

    inset = 64
    draw.rounded_rectangle(
        [inset, inset, W - inset, W - inset],
        radius=180,
        fill=(28, 44, 78, 255),
        outline=(50, 75, 120, 255),
        width=6,
    )

    # Book (cover + page edge)
    bx0, by0 = 170, 200
    bw, bh = 520, 640
    draw.rounded_rectangle([bx0, by0, bx0 + bw, by0 + bh], radius=28, fill=(42, 62, 108, 255))
    # Page block (right edge)
    draw.rounded_rectangle(
        [bx0 + bw - 72, by0 + 16, bx0 + bw - 10, by0 + bh - 16],
        radius=10,
        fill=(248, 242, 228, 255),
    )
    # Spine hint
    draw.rounded_rectangle([bx0 + 8, by0 + 16, bx0 + 22, by0 + bh - 16], radius=4, fill=(32, 48, 82, 255))

    # Watch dial on cover
    cx = bx0 + bw // 2 - 36
    cy = by0 + bh // 2
    r = 155
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(252, 248, 238, 255), outline=(24, 36, 58, 255), width=8)

    tick_outer = r - 14
    tick_inner = r - 36
    for i in range(12):
        ang = math.radians(i * 30 - 90)
        x1 = cx + int(tick_inner * math.cos(ang))
        y1 = cy + int(tick_inner * math.sin(ang))
        x2 = cx + int(tick_outer * math.cos(ang))
        y2 = cy + int(tick_outer * math.sin(ang))
        draw.line([(x1, y1), (x2, y2)], fill=(55, 70, 100, 255), width=5)

    def hand(angle_deg: float, length: float, width: int) -> None:
        rad = math.radians(angle_deg - 90)
        x2 = cx + int(length * math.cos(rad))
        y2 = cy + int(length * math.sin(rad))
        draw.line([(cx, cy), (x2, y2)], fill=(32, 44, 72, 255), width=width)

    hand(-70, r * 0.55, 14)
    hand(135, r * 0.38, 12)
    draw.ellipse([cx - 14, cy - 14, cx + 14, cy + 14], fill=(32, 44, 72, 255))

    img.save(path, "PNG")
    print(f"Wrote {path}")
    print("Run scripts/resize_watch_icons.sh to write AppIcon.appiconset/*.png")


if __name__ == "__main__":
    main()
