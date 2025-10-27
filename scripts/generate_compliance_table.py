#!/usr/bin/env python3
"""Generate a Markdown table listing every file in the repository and compliance items.

The script traverses the entire project tree (no exclusions) and extracts every file
path relative to the chosen root. It also parses compliance references from claude.md
and agents.md when they are present, capturing simple list items and headings. Results
are emitted as a Markdown table with a status column so each file can be marked OK/NOK
after revue. Output is printed to stdout or written to the chosen file.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Iterable, List, Sequence, Tuple


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan the project and generate a Markdown table of files and compliance items."
    )
    default_root = Path.cwd()
    parser.add_argument(
        "--root",
        type=Path,
        default=default_root,
        help=f"Root directory to scan (default: {default_root})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional path to write the Markdown table. When omitted, prints to stdout.",
    )
    parser.add_argument(
        "--compliance-files",
        nargs="*",
        default=("claude.md", "agents.md"),
        help="Markdown files containing compliance items to parse.",
    )
    parser.add_argument(
        "--default-file-status",
        default="TODO",
        help="Value placed in the status column for each file (e.g. OK, NOK, TODO).",
    )
    parser.add_argument(
        "--default-compliance-status",
        default="",
        help="Value placed in the status column for compliance references.",
    )
    return parser.parse_args()


def extract_compliance_items(path: Path) -> List[str]:
    """Extract list-like or heading lines from a Markdown file."""
    items: List[str] = []
    if not path.exists():
        return items

    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError as exc:
        sys.stderr.write(f"Warning: unable to read {path}: {exc}\n")
        return items

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        stripped = _strip_markdown_prefix(line)
        if stripped:
            items.append(stripped)
    return items


def _strip_markdown_prefix(line: str) -> str:
    """Remove common Markdown list and heading prefixes and return payload."""
    prefixes = ("- [x] ", "- [X] ", "- [ ] ", "- ", "* ", "+ ")
    for prefix in prefixes:
        if line.startswith(prefix):
            return line[len(prefix) :].strip()

    if line.startswith("#"):
        return line.lstrip("#").strip()

    parts = line.split(maxsplit=1)
    if parts and parts[0].rstrip(".").isdigit() and len(parts) == 2:
        return parts[1].strip()

    return ""


def gather_file_rows(root: Path, default_status: str) -> List[Tuple[str, str, str, str]]:
    """Collect every file path beneath root."""
    rows: List[Tuple[str, str, str, str]] = []
    for path in sorted(root.rglob("*")):
        if path.is_file():
            rel_path = path.relative_to(root).as_posix()
            rows.append(("file", rel_path, "filesystem", default_status))
    return rows


def gather_compliance_rows(
    root: Path, compliance_files: Sequence[str], default_status: str
) -> List[Tuple[str, str, str, str]]:
    """Collect compliance entries from the provided Markdown files."""
    rows: List[Tuple[str, str, str, str]] = []
    for name in compliance_files:
        file_path = root / name
        items = extract_compliance_items(file_path)
        if not items:
            if not file_path.exists():
                sys.stderr.write(f"Notice: compliance file not found (optional): {file_path}\n")
            continue
        for index, item in enumerate(items, start=1):
            rows.append(("compliance", item, f"{name}#{index}", default_status))
    return rows


def _escape_table_cell(value: str) -> str:
    return value.replace("|", "\\|")


def build_table(rows: Iterable[Tuple[str, str, str, str]]) -> str:
    lines = [
        "| Type | Item | Source | Status |",
        "|------|------|--------|--------|",
    ]
    for entry_type, item, source, status in rows:
        cells = [
            _escape_table_cell(entry_type),
            _escape_table_cell(item),
            _escape_table_cell(source),
            _escape_table_cell(status),
        ]
        lines.append("| " + " | ".join(cells) + " |")
    return "\n".join(lines)


def main() -> None:
    args = parse_args()
    root = args.root.resolve()
    if not root.exists():
        sys.stderr.write(f"Error: root directory does not exist: {root}\n")
        sys.exit(1)

    compliance_rows = gather_compliance_rows(
        root, args.compliance_files, args.default_compliance_status
    )
    file_rows = gather_file_rows(root, args.default_file_status)
    table = build_table([*compliance_rows, *file_rows])

    if args.output:
        output_path = args.output.resolve()
        try:
            output_path.write_text(table, encoding="utf-8")
        except OSError as exc:
            sys.stderr.write(f"Error: unable to write {output_path}: {exc}\n")
            sys.exit(1)
    else:
        print(table)


if __name__ == "__main__":
    main()
