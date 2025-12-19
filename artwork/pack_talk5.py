#!/usr/bin/env python3
"""Pack Scorch talk texts into 5-bit stream.

Reads artwork/talk.asm and generates artwork/talk_packed.asm.

Design goals:
- Keep the original artwork/talk.asm as editable source of strings.
- Generate a MADS-friendly .asm include with:
  - .proc talk (namespace-compatible)
  - talk5_alphabet (32 chars)
  - talk5_data: records of [len][packed bytes...]
  - constants (NumberOfOffensiveTexts, etc.) copied verbatim
  - hoverFull/hoverEmpty blocks copied verbatim (uncompressed)

Bit packing:
- 5-bit codes are packed LSB-first.
- For each string record:
  - 1 byte length (0..63)
  - packed bytes little-endian (first char in bits 0..4)

The decoder in 6502 should read 5-bit codes from the low bits.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Iterable, List, Tuple


# 32-symbol alphabet.
# Note: We intentionally omit 'X' to make room for punctuation.
# Order must match the decoder table.
ALPHABET = " ABCDEFGHIJKLMNOPQRSTUVWYZ'!,-.?"  # length must be 32


_DTA_STR_RE = re.compile(r"^\s*dta\s+d\"(.*?)\"\^\s*(?:;.*)?$")


def _iter_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8", errors="replace").splitlines()


def _find_section(lines: List[str], start_pat: re.Pattern[str], end_pat: re.Pattern[str]) -> Tuple[int, int]:
    start_idx = None
    for i, line in enumerate(lines):
        if start_pat.search(line):
            start_idx = i
            break
    if start_idx is None:
        raise ValueError(f"Start pattern not found: {start_pat.pattern}")

    for j in range(start_idx + 1, len(lines)):
        if end_pat.search(lines[j]):
            return start_idx, j
    raise ValueError(f"End pattern not found: {end_pat.pattern}")


def extract_talk_strings(lines: List[str]) -> List[str]:
    # Only pack strings inside `.proc talk` up to the `LEND` marker.
    proc_start, _ = _find_section(lines, re.compile(r"^\s*\.proc\s+talk\b"), re.compile(r"^\s*\.endp\b"))

    lend_idx = None
    for i in range(proc_start, len(lines)):
        if re.match(r"^\s*LEND\b", lines[i]):
            lend_idx = i
            break
    if lend_idx is None:
        raise ValueError("LEND marker not found inside .proc talk")

    strings: List[str] = []
    for line in lines[proc_start:lend_idx]:
        m = _DTA_STR_RE.match(line)
        if m:
            strings.append(m.group(1))

    if not strings:
        raise ValueError("No talk strings found to pack")

    return strings


def extract_constants_block(lines: List[str]) -> List[str]:
    # Copy constant definitions from after LEND up to `.endp` (inclusive of constants, exclusive of .endp).
    proc_start, proc_end = _find_section(lines, re.compile(r"^\s*\.proc\s+talk\b"), re.compile(r"^\s*\.endp\b"))

    lend_idx = None
    for i in range(proc_start, proc_end + 1):
        if re.match(r"^\s*LEND\b", lines[i]):
            lend_idx = i
            break
    if lend_idx is None:
        raise ValueError("LEND marker not found inside .proc talk")

    # Keep from LEND line through the line before `.endp`.
    return lines[lend_idx:proc_end]


def extract_tail_after_talk_proc(lines: List[str]) -> List[str]:
    # Copy everything after `.endp` for talk proc. This includes hoverFull/hoverEmpty.
    _, proc_end = _find_section(lines, re.compile(r"^\s*\.proc\s+talk\b"), re.compile(r"^\s*\.endp\b"))
    return lines[proc_end + 1 :]


def validate_alphabet() -> None:
    if len(ALPHABET) != 32:
        raise ValueError(f"ALPHABET must be 32 chars, got {len(ALPHABET)}")
    if len(set(ALPHABET)) != len(ALPHABET):
        raise ValueError("ALPHABET has duplicate characters")


def pack_string_5bit(s: str, mapping: dict[str, int]) -> bytes:
    if len(s) > 63:
        raise ValueError(f"String too long ({len(s)}): {s!r}")

    out = bytearray()
    out.append(len(s) & 0xFF)

    bitbuf = 0
    bitcount = 0

    for ch in s:
        try:
            code = mapping[ch]
        except KeyError as e:
            raise ValueError(f"Character {ch!r} not in alphabet") from e

        bitbuf |= (code & 0x1F) << bitcount
        bitcount += 5

        while bitcount >= 8:
            out.append(bitbuf & 0xFF)
            bitbuf >>= 8
            bitcount -= 8

    if bitcount:
        out.append(bitbuf & 0xFF)

    return bytes(out)


def format_dta_bytes(data: bytes, indent: str = "    ", per_line: int = 16) -> List[str]:
    lines: List[str] = []
    for i in range(0, len(data), per_line):
        chunk = data[i : i + per_line]
        nums = ",".join(f"${b:02x}" for b in chunk)
        lines.append(f"{indent}dta b({nums})")
    return lines


def generate_output(
    source_path: Path,
    strings: List[str],
    constants_block: List[str],
    tail_lines: List[str],
) -> str:
    mapping = {ch: i for i, ch in enumerate(ALPHABET)}

    packed_records: List[bytes] = [pack_string_5bit(s, mapping) for s in strings]

    out_lines: List[str] = []
    out_lines.append("; AUTO-GENERATED FILE - DO NOT EDIT")
    out_lines.append(f"; Generated by {source_path.name} -> pack_talk5.py")
    out_lines.append("; Source: artwork/talk.asm")
    out_lines.append("")

    out_lines.append(".proc talk")
    out_lines.append("; 5-bit packed talk strings (len + packed bytes)")
    out_lines.append(f"talk5_alphabet dta d\"{ALPHABET}\"")
    out_lines.append("talk5_data")

    for rec in packed_records:
        out_lines.extend(format_dta_bytes(rec))

    out_lines.append(";")
    out_lines.append("; Constants copied from source")
    out_lines.extend(constants_block)
    out_lines.append(".endp")

    if tail_lines:
        out_lines.append("")
        out_lines.append("; Tail copied from source (uncompressed)")
        out_lines.extend(tail_lines)

    out_lines.append("")
    return "\n".join(out_lines)


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Pack artwork/talk.asm into a 5-bit blob for MADS.")
    parser.add_argument(
        "--src",
        default="artwork/talk.asm",
        help="Path to source talk.asm (default: artwork/talk.asm)",
    )
    parser.add_argument(
        "--out",
        default="artwork/talk_packed.asm",
        help="Path to output .asm include (default: artwork/talk_packed.asm)",
    )

    args = parser.parse_args(argv)

    validate_alphabet()

    src_path = Path(args.src)
    out_path = Path(args.out)

    lines = _iter_lines(src_path)
    strings = extract_talk_strings(lines)
    constants_block = extract_constants_block(lines)
    tail_lines = extract_tail_after_talk_proc(lines)

    content = generate_output(src_path, strings, constants_block, tail_lines)

    out_path.write_text(content, encoding="utf-8")
    print(f"Wrote {out_path} ({len(content.encode('utf-8'))} bytes text)")
    print(f"Packed {len(strings)} strings")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
