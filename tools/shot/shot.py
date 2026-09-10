# -*- coding: utf-8 -*-
"""Screenshots for a fraction of the tokens.

A 1100x760 grab of the gallery costs about 1100 image tokens to look at, and
most of them are spent on whitespace nowhere near the thing being checked.
This trims that bill in three steps, cheapest first:

  1. `inspect` answers geometry questions with numbers instead of pixels.
     "Is the glyph centred in its button?" is a bounding box, not a picture,
     and a bounding box costs a dozen tokens.
  2. `prep` crops to the region that matters, scales it down to a sane long
     side and re-encodes it as an 8-bit palette PNG. Interface screenshots
     have few colours, so that is usually a 3-5x size cut with no visible
     loss.
  3. What is left goes to a cheap model: hand the prepared file to a Haiku
     subagent and keep its answer, not the image, in the main context.

     Agent(subagent_type: "general-purpose", model: "haiku",
           prompt: "Read <path> and report ...")

  Commands
    capture  run the demo app (or any of its flags) and grab a PNG
    prep     crop / zoom / shrink / requantise a PNG for reading
    inspect  print numbers about a PNG -- size, content box, pixel colours

  Examples
    python tools/shot/shot.py capture --out toast.png --app-args "--toast"
    python tools/shot/shot.py prep toast.png --crop 900,20,340,110 --zoom 2
    python tools/shot/shot.py inspect toast.png --crop 900,20,340,110 --box
"""
import argparse
import os
import subprocess
import sys

from PIL import Image, ImageChops

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))

DEFAULT_BUILD = os.path.join(
    REPO, "build", "Desktop_Qt_6_11_0_MSVC2022_64bit-Debug")
DEFAULT_QT_BIN = r"C:\Qt\6.11.0\msvc2022_64\bin"


def parse_box(text):
    parts = [int(p) for p in text.replace(" ", "").split(",")]
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("expected x,y,w,h")
    return tuple(parts)


def parse_point(text):
    parts = [int(p) for p in text.replace(" ", "").split(",")]
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("expected x,y")
    return tuple(parts)


def load(path, crop=None):
    image = Image.open(path).convert("RGBA")
    if crop:
        x, y, w, h = crop
        image = image.crop((x, y, x + w, y + h))
    return image


def human(size):
    return "%.1f KB" % (size / 1024.0)


# ---------------------------------------------------------------- capture

def capture(args):
    exe = os.path.join(args.build, args.exe)
    if not os.path.exists(exe):
        sys.exit("no such executable: " + exe)

    out = os.path.abspath(args.out)
    env = dict(os.environ)
    # The Qt DLLs are not on PATH in a plain shell, and without them the
    # process dies with 0xc0000135 before it can say why.
    env["PATH"] = args.qt_bin + os.pathsep + env.get("PATH", "")

    command = [exe, "--width", str(args.width), "--height", str(args.height)]
    if args.theme:
        command += ["--theme", args.theme]
    if args.scroll is not None:
        command += ["--scroll", str(args.scroll)]
    if args.app_args:
        command += args.app_args.split()
    command += ["--shot-window", out]

    result = subprocess.run(command, env=env, capture_output=True, text=True)
    noise = [line for line in (result.stderr or "").splitlines()
             if line.strip() and "QML debugging" not in line
             and "items in the process of being created" not in line]
    for line in noise[:20]:
        print("app: " + line)
    if not os.path.exists(out):
        sys.exit("no screenshot was written (exit %d)" % result.returncode)

    with Image.open(out) as image:
        print("captured %s  %dx%d  %s"
              % (out, image.width, image.height, human(os.path.getsize(out))))
    return out


# ------------------------------------------------------------------- prep

def content_box(image, background=None):
    """The box outside which every pixel matches the corner colour."""
    flat = image.convert("RGB")
    if background is None:
        background = flat.getpixel((0, 0))
    plain = Image.new("RGB", flat.size, background)
    box = ImageChops.difference(flat, plain).getbbox()
    return box


def prep(args):
    source = os.path.abspath(args.image)
    image = load(source, args.crop)

    if args.trim:
        box = content_box(image)
        if box:
            image = image.crop(box)

    if args.zoom != 1:
        # Nearest neighbour on purpose: a zoom is asked for to look at
        # pixel edges, and smoothing them away defeats the point.
        image = image.resize((int(image.width * args.zoom),
                              int(image.height * args.zoom)), Image.NEAREST)

    longest = max(image.width, image.height)
    if longest > args.max_side:
        scale = args.max_side / float(longest)
        image = image.resize((max(1, int(image.width * scale)),
                              max(1, int(image.height * scale))),
                             Image.LANCZOS)

    if args.grid:
        image = draw_grid(image, args.grid)

    out = args.out or os.path.join(
        os.path.dirname(source),
        os.path.splitext(os.path.basename(source))[0] + ".small.png")
    out = os.path.abspath(out)

    # Interface screenshots hold a few dozen colours, so a palette costs
    # nothing visually and cuts the file by several times.
    saveable = image.convert("RGB")
    if not args.no_quantize:
        saveable = saveable.quantize(colors=args.colors, method=Image.MEDIANCUT)
    saveable.save(out, optimize=True)

    before = os.path.getsize(source)
    after = os.path.getsize(out)
    with Image.open(source) as original:
        was = original.width * original.height
        original_size = original.size
    now = image.width * image.height

    print("%s  %dx%d  %s  (was %dx%d, %s)"
          % (out, image.width, image.height, human(after),
             original_size[0], original_size[1], human(before)))
    # A vision model bills roughly one token per 750 pixels of input.
    print("~%d image tokens instead of ~%d" % (now // 750 + 1, was // 750 + 1))
    return out


def draw_grid(image, step):
    """A faint ruler over the picture, for questions about position."""
    from PIL import ImageDraw

    marked = image.convert("RGBA").copy()
    draw = ImageDraw.Draw(marked, "RGBA")
    for x in range(0, marked.width, step):
        heavy = (x // step) % 5 == 0
        draw.line([(x, 0), (x, marked.height)],
                  fill=(255, 0, 255, 110 if heavy else 45))
        if heavy and x:
            draw.text((x + 1, 1), str(x), fill=(255, 0, 255, 200))
    for y in range(0, marked.height, step):
        heavy = (y // step) % 5 == 0
        draw.line([(0, y), (marked.width, y)],
                  fill=(255, 0, 255, 110 if heavy else 45))
        if heavy and y:
            draw.text((1, y + 1), str(y), fill=(255, 0, 255, 200))
    return marked


# ---------------------------------------------------------------- inspect

def inspect(args):
    source = os.path.abspath(args.image)
    with Image.open(source) as probe:
        full = probe.size
    image = load(source, args.crop)
    origin = (args.crop[0], args.crop[1]) if args.crop else (0, 0)

    print("file   %s" % source)
    print("size   %dx%d" % full)
    if args.crop:
        print("crop   x=%d y=%d w=%d h=%d" % args.crop)

    if args.box:
        box = content_box(image)
        if box is None:
            print("box    empty -- every pixel matches the corner colour")
        else:
            left, top, right, bottom = box
            print("box    x=%d..%d y=%d..%d  (%dx%d)"
                  % (left + origin[0], right + origin[0],
                     top + origin[1], bottom + origin[1],
                     right - left, bottom - top))
            # The two gaps that answer "is this centred?" without a picture.
            print("gaps   left=%d right=%d top=%d bottom=%d"
                  % (left, image.width - right, top, image.height - bottom))

    if args.mask:
        target = tuple(int(args.mask[i:i + 2], 16) for i in (0, 2, 4))
        flat = image.convert("RGB")
        pixels = flat.load()
        left, top, right, bottom, count = None, None, None, None, 0
        for y in range(flat.height):
            for x in range(flat.width):
                r, g, b = pixels[x, y]
                if (abs(r - target[0]) <= args.mask_tolerance
                        and abs(g - target[1]) <= args.mask_tolerance
                        and abs(b - target[2]) <= args.mask_tolerance):
                    count += 1
                    left = x if left is None else min(left, x)
                    right = x if right is None else max(right, x)
                    top = y if top is None else min(top, y)
                    bottom = y if bottom is None else max(bottom, y)
        if count == 0:
            print("mask   #%s +-%d: no pixels" % (args.mask, args.mask_tolerance))
        else:
            print("mask   #%s +-%d: %d px, x=%d..%d y=%d..%d (%dx%d)"
                  % (args.mask, args.mask_tolerance, count,
                     left + origin[0], right + origin[0],
                     top + origin[1], bottom + origin[1],
                     right - left + 1, bottom - top + 1))

    if args.probe:
        x, y = args.probe
        pixel = image.getpixel((x - origin[0], y - origin[1]))
        print("pixel  (%d,%d) = #%02x%02x%02x alpha=%d" % ((x, y) + pixel))

    if args.colors:
        counted = image.convert("RGB").getcolors(maxcolors=1 << 20) or []
        counted.sort(reverse=True)
        print("colors %d distinct, most common:" % len(counted))
        for count, rgb in counted[:args.colors]:
            print("       #%02x%02x%02x  %d px" % (rgb + (count,)))


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    grab = sub.add_parser("capture", help="run the app and grab a PNG")
    grab.add_argument("--out", required=True)
    grab.add_argument("--build", default=DEFAULT_BUILD)
    grab.add_argument("--exe", default="qgravityui_gallery.exe")
    grab.add_argument("--qt-bin", default=DEFAULT_QT_BIN)
    grab.add_argument("--width", type=int, default=1100)
    grab.add_argument("--height", type=int, default=760)
    grab.add_argument("--theme")
    grab.add_argument("--scroll", type=int)
    grab.add_argument("--app-args", default="",
                      help="extra flags for the demo, e.g. \"--toast --open\"")
    grab.set_defaults(func=capture)

    small = sub.add_parser("prep", help="crop / zoom / shrink for reading")
    small.add_argument("image")
    small.add_argument("--out")
    small.add_argument("--crop", type=parse_box, help="x,y,w,h")
    small.add_argument("--zoom", type=float, default=1)
    small.add_argument("--max-side", type=int, default=700)
    small.add_argument("--trim", action="store_true",
                       help="drop the uniform margin around the content")
    small.add_argument("--grid", type=int, metavar="STEP",
                       help="overlay a ruler every STEP px")
    small.add_argument("--colors", type=int, default=64)
    small.add_argument("--no-quantize", action="store_true")
    small.set_defaults(func=prep)

    facts = sub.add_parser("inspect", help="numbers instead of pixels")
    facts.add_argument("image")
    facts.add_argument("--crop", type=parse_box, help="x,y,w,h")
    facts.add_argument("--box", action="store_true",
                       help="content bounding box and the gaps around it")
    facts.add_argument("--probe", type=parse_point, metavar="X,Y")
    facts.add_argument("--mask", metavar="RRGGBB",
                       help="bounding box of the pixels matching this colour")
    facts.add_argument("--mask-tolerance", type=int, default=8)
    facts.add_argument("--colors", type=int, metavar="N", default=0,
                       help="list the N most common colours")
    facts.set_defaults(func=inspect)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
