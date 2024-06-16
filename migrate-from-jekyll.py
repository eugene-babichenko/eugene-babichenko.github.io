import os
import pathlib
import shutil

FRONT_MATTER = """
---
render: false
transparent: true
redirect_to: "/blog/"
---
"""

BASE = "content/blog/"

files = os.listdir(BASE)

for file in files:
    if file == "_index.md":
        continue
    sections = file.split("-")[:3]
    pf = BASE + "/".join(sections)
    pathlib.Path(pf).mkdir(parents=True, exist_ok=True)
    for i in range(1, 4):
        p = BASE + "/".join(sections[:i]) + "/_index.md"
        with open(p, "w") as f:
            print(FRONT_MATTER, file=f)
    shutil.move(BASE + file, pf + "/" + file)
