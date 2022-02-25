#!/bin/sh
set -e


echo "Build with gftools builder"
gftools builder config.yaml

echo "Slice into Roman and Italic VF (as Google Fonts currently doesn't support slnt or ital axes)"

fonttools varLib.instancer "../fonts/variable/Anybody[ital,wdth,wght].ttf" ital=0 --update-name-table -o "../fonts/variable/Anybody[wdth,wght].ttf"
fonttools varLib.instancer "../fonts/variable/Anybody[ital,wdth,wght].ttf" ital=1 --update-name-table -o "../fonts/variable/Anybody-Italic[wdth,wght].ttf"

echo "Fix name ID 25"
gftools gen-stat "../fonts/variable/Anybody-Italic[wdth,wght].ttf" --axis-order 'wdth' 'wght' 'ital' --inplace

echo "Fix style linking"
python3 fix.py

echo "fix statics and create webfonts"
ttf=$(ls ../fonts/ttf/*.ttf)
for font in $ttf
do
    ttfautohint $font $font.fix
    mv $font.fix $font
    gftools fix-hinting $font
    mv $font.fix $font
    fonttools ttLib.woff2 compress $font
done

rm -rf ../fonts/webfonts
mkdir ../fonts/webfonts
mv ../fonts/ttf/*.woff2 ../fonts/webfonts/

echo "Complete"
