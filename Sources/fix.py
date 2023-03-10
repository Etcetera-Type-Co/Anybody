import glob
from fontTools.ttLib import TTFont
from fontbakery.constants import (
    MacStyle,
    FsSelection,
)

if __name__ == "__main__":

    for font_path in glob.glob("../fonts/variable/*Italic*.ttf"):
        with open(font_path, "rb") as f:
            print("Fix italic name id 6 in {}".format(font_path))
            ttFont = TTFont(f)
            ttFont["name"].setName("Anybody-ThinItalic", 6, 3, 1, 0x409)
            ttFont["name"].setName("1.114;ETCO;Anybody-ThinItalic", 3, 3, 1, 0x409)
            ttFont.save(font_path)