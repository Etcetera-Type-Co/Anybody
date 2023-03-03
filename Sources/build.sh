#!/bin/sh
set -e


echo "Build with gftools builder"
gftools builder config.yaml

echo "Move default instance to regular"
fonttools varLib.instancer "../fonts/variable/Anybody[wdth,wght].ttf" wdth=25:100:150 --update-name-table -o "../fonts/variable/Anybody[wdth,wght].ttf"

echo "Move default instance to regular"
fonttools varLib.instancer "../fonts/variable/Anybody-Italic[wdth,wght].ttf" wdth=25:100:150 --update-name-table -o "../fonts/variable/Anybody-Italic[wdth,wght].ttf"

echo "Fix nameID 6 (fonttools whatever bug)"
python3 fix.py

echo "Complete"
