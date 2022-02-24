#!/bin/sh
set -e


echo "Build with gftools builder"
gftools builder config.yaml

echo "Slice into Roman and Italic VF (as Google Fonts currently doesn't support slnt or ital axes)"

fonttools varLib.instancer "../fonts/variable/Anybody[ital,wdth,wght].ttf" ital=0 --update-name-table -o "../fonts/variable/Anybody[wdth,wght].ttf"
fonttools varLib.instancer "../fonts/variable/Anybody[ital,wdth,wght].ttf" ital=1 --update-name-table -o "../fonts/variable/Anybody-Italic[wdth,wght].ttf"

echo "Fix name ID 25"
gftools gen-stat "../fonts/variable/Anybody-Italic[wdth,wght].ttf" --axis-order 'wdth' 'wght' 'ital' --inplace

echo "Fix Italic bits"
python3 fix.py

echo "Complete"
