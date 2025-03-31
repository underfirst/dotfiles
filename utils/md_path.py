from argparse import ArgumentParser
from os import environ
from pathlib import Path
from urllib.parse import urlparse

parser = ArgumentParser()
parser.add_argument("--path")
parser.add_argument("--name", default="")
args = parser.parse_args()


def convert_dir(url: str, name: str = "") -> str:
    url_parsed = urlparse(url)
    ret = f"{environ['HOME']}/Documents/notes/{url_parsed.netloc}{url_parsed.path}"
    if not ret.endswith("/"):
        ret = f"{ret}/"
        Path(ret).mkdir(exist_ok=True, parents=True)
    if name != "":
        ret = f"{ret}{name}"
    ret = Path(ret)
    ret.parent.mkdir(exist_ok=True, parents=True)
    return str(ret)


print(convert_dir(args.path, args.name), end="")
