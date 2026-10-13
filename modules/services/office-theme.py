# office-theme.py APP_CSS COLORS_JSON OUT: onlyoffice's built-in dark theme
# recolored, as OUT/themes.json, where files.<domain>'s "dark" is defined,
# and OUT/theme.css, which applies the colors. grays move to the step of
# base00..base07 at the same rank of lightness, colors to the base of the
# nearest hue
import colorsys
import json
import re
import sys

css = open(sys.argv[1]).read()
colors = json.load(open(sys.argv[2]))

block = next(
    m.group(1)
    for m in re.finditer(r"theme-type-dark[^{}]*\{([^}]*)\}", css)
    if "--background-normal" in m.group(1)
)
dark = dict(re.findall(r"--([a-z0-9-]+):\s*(#[0-9a-fA-F]{3,6})\s*(?:;|$)", block))


def rgb(hex):
    hex = hex.lstrip("#")
    if len(hex) == 3:
        hex = "".join(c * 2 for c in hex)
    return tuple(int(hex[i : i + 2], 16) / 255 for i in (0, 2, 4))


def to_hex(c):
    return "#" + "".join(f"{round(x * 255):02x}" for x in c)


def mix(a, b):
    return tuple((x + y) / 2 for x, y in zip(a, b))


bases = [rgb(colors[f"base0{i}"]) for i in range(8)]
ramp = []
for i in range(7):
    ramp += [bases[i], mix(bases[i], bases[i + 1])]
ramp.append(bases[7])

hues = {f"base0{k}": colorsys.rgb_to_hls(*rgb(colors[f"base0{k}"]))[0] for k in "89ABCDE"}

grays = sorted(
    {v.lower() for v in dark.values() if colorsys.rgb_to_hls(*rgb(v))[2] < 0.2},
    key=lambda v: colorsys.rgb_to_hls(*rgb(v))[1],
)
step = {
    v: to_hex(ramp[round(i * (len(ramp) - 1) / max(len(grays) - 1, 1))])
    for i, v in enumerate(grays)
}


def recolor(v):
    v = v.lower()
    if v in step:
        return step[v]
    h = colorsys.rgb_to_hls(*rgb(v))[0]
    near = min(hues, key=lambda b: min(abs(hues[b] - h), 1 - abs(hues[b] - h)))
    return colors[near]


out = sys.argv[3]
theme = {k: recolor(v) for k, v in sorted(dark.items())}

with open(f"{out}/themes.json", "w") as f:
    json.dump({"themes": [{"id": "dark", "name": "Dark", "type": "dark", "colors": theme}]}, f)

# above its own dark theme, which sits on the same element
with open(f"{out}/theme.css", "w") as f:
    f.write(":root body.theme-type-dark {\n")
    f.writelines(f"  --{k}: {v};\n" for k, v in theme.items())
    f.write("}\n")
