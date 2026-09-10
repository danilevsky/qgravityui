#!/usr/bin/env python3
"""Whitespace and encoding gate for the QML sources.

Why this and not `qmlformat --check`: qmlformat reflows every expression it
can fit on one line, and this library's sources are laid out as tables that
mirror the upstream CSS -- the `view` switch in GButton, the size ladders in
ComponentMetrics -- aligned by hand so a QML line sits next to the CSS rule
it ports. Running qmlformat over the tree rewrites all 80 files and loses
that; the diff was measured (3864 changed lines in examples/gallery/Main.qml alone) before
this was written. What is left of a formatter's job that is still objective --
line endings, tabs, trailing blanks, a final newline, no BOM -- is enforced
here, and `qmllint` carries the actual style and correctness rules.

    python tools/qml-check/qml_check.py [--fix]
"""

import argparse
import pathlib
import sys

ROOTS = ("src", "examples", "tests")
SUFFIXES = (".qml", ".metainfo")


def sources(repo):
    for root in ROOTS:
        for suffix in SUFFIXES:
            for path in sorted((repo / root).rglob("*" + suffix)):
                if "build" not in path.parts:
                    yield path


def check(path):
    raw = path.read_bytes()
    problems = []
    if raw.startswith(b"\xef\xbb\xbf"):
        problems.append("UTF-8 BOM")
    if b"\r\n" in raw:
        problems.append("CRLF line endings")
    if b"\t" in raw:
        problems.append("tab indentation")
    if raw and not raw.endswith(b"\n"):
        problems.append("no final newline")
    if raw.endswith(b"\n\n"):
        problems.append("blank line at end of file")
    for number, line in enumerate(raw.split(b"\n"), start=1):
        if line.rstrip(b"\r") != line.rstrip():
            problems.append("trailing whitespace on line %d" % number)
            break
    return problems


def fix(path):
    raw = path.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    raw = raw.replace(b"\r\n", b"\n").replace(b"\t", b"    ")
    raw = b"\n".join(line.rstrip() for line in raw.split(b"\n"))
    raw = raw.rstrip(b"\n") + b"\n"
    path.write_bytes(raw)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fix", action="store_true",
                        help="rewrite the offending files instead of failing")
    arguments = parser.parse_args()

    repo = pathlib.Path(__file__).resolve().parents[2]
    failed = 0
    checked = 0
    for path in sources(repo):
        checked += 1
        problems = check(path)
        if not problems:
            continue
        relative = path.relative_to(repo).as_posix()
        if arguments.fix:
            fix(path)
            print("fixed %s (%s)" % (relative, ", ".join(problems)))
        else:
            failed += 1
            print("%s: %s" % (relative, "; ".join(problems)))
    print("qml-check: %d files checked, %d with problems" % (checked, failed))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
