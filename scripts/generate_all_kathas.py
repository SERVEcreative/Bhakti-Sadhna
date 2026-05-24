#!/usr/bin/env python3
"""Generate assets/content/katha/{deity_id}.json from katha_bundle and chapter files."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets/content/katha"
CH_DIR = ROOT / "assets/content/katha/chapters"

# Ensure scripts/ is importable when run from project root.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from katha_bundle import get_kathas  # noqa: E402

SATYANARAYAN_CHAPTER_TITLES = [
    "प्रथम अध्याय",
    "दूसरा अध्याय",
    "तीसरा अध्याय",
    "चौथा अध्याय",
    "पांचवा अध्याय",
]

ALL_DEITY_IDS = [
    "ganesh", "shiva", "vishnu", "lakshmi", "hanuman", "durga", "krishna", "ram",
    "saraswati", "kali", "sai", "shani", "surya", "kartikeya", "radha", "parvati",
    "jagannath", "balaji", "narasimha", "gayatri", "annapurna", "ganga",
    "satyanarayan", "kubera",
]


def _split_paragraphs(text: str) -> list[str]:
    return [p.strip() for p in re.split(r"\n\s*\n", text.strip()) if p.strip()]


def build_satyanarayan() -> dict:
    """Load satyanarayan_01.txt … 05.txt as five chapters in one section."""
    chapters = []
    for i, title in enumerate(SATYANARAYAN_CHAPTER_TITLES, start=1):
        path = CH_DIR / f"satyanarayan_{i:02d}.txt"
        if not path.exists():
            raise FileNotFoundError(f"Missing chapter file: {path}")
        chapters.append(
            {
                "titleHi": title,
                "paragraphsHi": _split_paragraphs(path.read_text(encoding="utf-8")),
            }
        )
    return {
        "titleHi": "श्री सत्यनारायण व्रत कथा",
        "sections": [
            {
                "titleHi": "संपूर्ण व्रत कथा",
                "chapters": chapters,
            }
        ],
    }


def count_paragraphs(doc: dict) -> int:
    total = 0
    for section in doc.get("sections", []):
        total += len(section.get("paragraphsHi", []))
        for chapter in section.get("chapters", []):
            total += len(chapter.get("paragraphsHi", []))
    return total


def main() -> None:
    kathas = get_kathas()
    kathas["satyanarayan"] = build_satyanarayan()

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Generating katha JSON files…\n")
    summary: list[tuple[str, int, int]] = []

    for deity_id in ALL_DEITY_IDS:
        if deity_id not in kathas:
            print(f"WARNING: no content for {deity_id}, skipping")
            continue
        doc = kathas[deity_id]
        out_path = OUT_DIR / f"{deity_id}.json"
        out_path.write_text(
            json.dumps(doc, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        para_count = count_paragraphs(doc)
        section_count = len(doc.get("sections", []))
        summary.append((deity_id, section_count, para_count))
        print(f"  {deity_id:14s}  →  {out_path.name}  ({section_count} sections, {para_count} paragraphs)")

    print("\n" + "=" * 60)
    print(f"{'Deity':<16} {'Sections':>8} {'Paragraphs':>12}")
    print("-" * 60)
    total_paras = 0
    for deity_id, sections, paras in summary:
        print(f"{deity_id:<16} {sections:>8} {paras:>12}")
        total_paras += paras
    print("-" * 60)
    print(f"{'TOTAL':<16} {len(summary):>8} {total_paras:>12}")
    print("=" * 60)


if __name__ == "__main__":
    main()
