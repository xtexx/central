# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "click>=8.3.1",
#     "wlc>=1.17.2",
# ]
# ///

from concurrent.futures import ThreadPoolExecutor

import click
from click import echo
from wlc import Translation, Unit, Weblate
from wlc.config import WeblateConfig


@click.command()
@click.argument("project")
@click.argument("component")
@click.argument("lang")
def main(project: str, component: str, lang: str) -> None:
    config = WeblateConfig()
    config.load()
    wlc = Weblate(config=config)
    wlc_trans: Translation = wlc.get_translation(f"{project}/{component}/{lang}")

    with ThreadPoolExecutor(max_workers=6) as executor:
        for unit in wlc_trans.units(q="state:translated"):
            unit: Unit = unit
            echo(f"{unit.context}")
            try:
                executor.submit(approve, unit).result(0.01)
            except TimeoutError:
                pass

        echo("Finished! Waiting for upload ...")
        executor.shutdown(wait=True, cancel_futures=False)

    echo("Finished")


def approve(unit: Unit):
    unit.patch(state=30, target=unit.target)


if __name__ == "__main__":
    main()
