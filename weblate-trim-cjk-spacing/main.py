# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "click>=8.3.1",
#     "wlc>=1.17.2",
# ]
# ///

from concurrent.futures import ThreadPoolExecutor
import re
from typing import cast

import click
from click import confirm, echo
from wlc import Component, Translation, Unit, Weblate
from wlc.config import WeblateConfig

cjkChars = (
    # BMP
    r"\u2e80-\u2eff"  # CJK Radicals Supplement
    r"\u2f00-\u2fdf"  # Kangxi Radicals
    r"\u3000-\u303f"  # CJK Symbols and Punctuation
    r"\u3040-\u309f"  # Hiragana
    r"\u30a0-\u30ff"  # Katakana
    r"\u3100-\u312f"  # Bopomofo
    r"\u31a0-\u31bf"  # Bopomofo Extended
    r"\u31c0-\u31ef"  # CJK Strokes
    r"\u3200-\u32ff"  # Enclosed CJK Letters and Months
    r"\u3300-\u33ff"  # CJK Compatibility
    r"\u3400-\u4dbf"  # CJK Unified Ideographs Extension A
    r"\u3200-\u32ff"  # Enclosed CJK Letters and Months
    r"\u4e00-\u9fff"  # CJK Unified Ideographs
    r"\uf900-\ufaff"  # CJK Compatibility Ideographs
    r"\ufe30-\ufe4f"  # CJK Compatibility Forms
    r"\ufe50-\ufe6f"  # Small Form Variants
    r"\uff00-\uffef"  # Halfwidth and Fullwidth Forms
    # SMP and TIP
    r"\U00016fe0-\U00016fff"  # Ideographic Symbols and Punctuation
    r"\U0001f200-\U0001f2ff"  # Enclosed Ideographic Supplement
    r"\U00020000-\U0002a6df"  # CJK Unified Ideographs Extension B
    r"\U0002a700-\U0002b73f"  # CJK Unified Ideographs Extension C
    r"\U0002b740-\U0002b81f"  # CJK Unified Ideographs Extension D
    r"\U0002b820-\U0002ceaf"  # CJK Unified Ideographs Extension E
    r"\U0002ceb0-\U0002ebef"  # CJK Unified Ideographs Extension F
    r"\U0002ebf0-\U0002ee5f"  # CJK Unified Ideographs Extension I
    r"\U0002f800-\U0002fa1f"  # CJK Compatibility Ideographs Supplement
    r"\U00030000-\U0003134f"  # CJK Unified Ideographs Extension G
    r"\U00031350-\U000323af"  # CJK Unified Ideographs Extension H
    r"\U000323b0-\U0003347f"  # CJK Unified Ideographs Extension J
    # Small areas
    r"\u2012-\u2015\u2053"  # General Punctuation, dashes
    r"\u2018\u2019\u201b-\u201f"  # General Punctuation, quotation marks and apostrophe
    r"\u2026\u2027"  # General Punctuation, ellipsis and hyphen
)
cjkPunctuations = {
    r"......": r"……",
    r"...": r"……",
    r",": r"，",
    r":": r"：",
    r";": r"；",
    r"?": r"？",
    r"!": r"！",
    r"(": r"（",
    r")": r"）",
}
# Only fix strings ends with these half-width punctuations
cjkStops = {
    r".": r"。",  # Fixing . in the middle of string make too many false positives.
}
regexCjk = f"[{cjkChars}]"
regexNonCjk = f"[^{cjkChars}]"
regexSpace = r"(?:[\s\u00a0]|(?:\xc2\xa0))"
regexEdge1 = re.compile(f"({regexCjk}){regexSpace}+({regexNonCjk})")
regexEdge2 = re.compile(f"({regexNonCjk}){regexSpace}+({regexCjk})")


@click.command()
@click.argument("project")
@click.argument("component")
@click.option("--lang")
@click.option("--submit", flag_value=True, default=False)
def main(project: str, component: str, submit: bool, lang: str | None) -> None:
    config = WeblateConfig()
    config.load()
    wlc = Weblate(config=config)
    wlc_component: Component = wlc.get_component(f"{project}/{component}")
    langs: list[str] = (
        [lang] if lang else [c.language.code for c in wlc_component.list()]
    )
    echo(f"Regex: {cjkChars}")
    echo(f"Languages: {', '.join(langs)}")

    with ThreadPoolExecutor(max_workers=3) as executor:
        for lang in langs:
            echo(f"Processing {lang} ...")
            wlc_trans: Translation = wlc.get_translation(
                f"{project}/{component}/{lang}"
            )
            i = 0
            for unit in wlc_trans.units(q="state:>empty"):
                i += 1
                unit: Unit = unit
                echo(f"  {i}/{wlc_trans.translated}: {unit.context}:")
                old_targets = cast(list[str], unit.target)
                new_targets = [fix_target_str(s) for s in old_targets]
                for old_target, new_target in zip(old_targets, new_targets):
                    if old_target != new_target:
                        echo(f"    - {old_target} => {new_target}")
                if submit and old_targets != new_targets:
                    try:
                        executor.submit(patch, unit, new_targets).result(0.01)
                    except TimeoutError:
                        pass

        echo("Finished! Waiting for upload ...")
        executor.shutdown(wait=True, cancel_futures=False)

    echo("Yeah!!")


def fix_target_str(target: str) -> str:
    # Strip strings
    target = target.strip(" \n`")

    # Remove manual spacing
    # loop to handle overlapping matches like "non-CJK space CJK space non-CJK"
    while True:
        new_target = regexEdge1.sub(r"\1\2", target)
        new_target = regexEdge2.sub(r"\1\2", new_target)
        if new_target == target:
            break
        target = new_target

    # Unify half-width and full-width punctuations
    new_target = target
    for half_punc, full_punc in cjkPunctuations.items():
        if half_punc in new_target:
            new_target = new_target.replace(half_punc, full_punc)

    for half_punc, full_punc in cjkStops.items():
        if new_target.endswith(half_punc):
            new_target = new_target.rstrip(half_punc) + full_punc

    # Unify space usages
    for _, full_punc in [*cjkPunctuations.items(), *cjkStops.items()]:
        new_target = re.sub(f"{full_punc}\\s+", full_punc, new_target)

    new_target = new_target.replace("https：//", "https://")
    new_target = new_target.replace("HTTP（S）", "HTTP(S)")

    if target != new_target:
        target = (
            new_target
            if confirm(f"Fix? {target} => {new_target}", default=True)
            else target
        )

    # Unify usage of … and ……
    target = target.replace("……", "…").replace("…", "……")

    return target


def patch(unit: Unit, target: list[str]):
    unit.patch(state=unit.state, target=target)


if __name__ == "__main__":
    main()
