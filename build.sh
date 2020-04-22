#!/bin/sh

#requires fontmake and Skia Pathops https://github.com/fonttools/skia-pathops


set -e


cd sources

echo "Generating Static fonts"
mkdir -p ../fonts/static/ttf
fontmake --overlaps-backend pathops -g Anybody.glyphs -i -o ttf --output-dir ../fonts/static/ttf/

mkdir -p ../fonts/static/otf
fontmake --overlaps-backend pathops -g Anybody.glyphs -i -o otf --output-dir ../fonts/static/otf/


cd ..

# ============================================================================
# Autohinting ================================================================
statics=$(ls fonts/static/ttf/*.ttf)
echo hello
for file in $statics; do
    echo "fix DSIG in " ${file}
    gftools fix-dsig --autofix ${file}

    echo "TTFautohint " ${file}
    # autohint with detailed info
    hintedFile=${file/".ttf"/"-hinted.ttf"}
    ttfautohint -I ${file} ${hintedFile}
    cp ${hintedFile} ${file}
    rm -rf ${hintedFile}
done

echo "Post processing OTFs"
otfs=$(ls fonts/static/otf/*.otf)
for otf in $otfs
do
	gftools fix-dsig -f $otf
done
# ============================================================================
# Build woff2 fonts ==========================================================

# requires https://github.com/bramstein/homebrew-webfonttools

rm -rf fonts/web/woff2

ttfs=$(ls fonts/static/ttf/*.ttf)
for ttf in $ttfs; do
    woff2_compress $ttf
done

mkdir -p fonts/web/woff2
woff2s=$(ls fonts/static/*/*.woff2)
for woff2 in $woff2s; do
    mv $woff2 fonts/web/woff2/$(basename $woff2)
done
# ============================================================================
# Build woff fonts ==========================================================

# requires https://github.com/bramstein/homebrew-webfonttools

rm -rf fonts/web/woff

ttfs=$(ls fonts/static/ttf/*.ttf)
for ttf in $ttfs; do
    sfnt2woff-zopfli $ttf
done

mkdir -p fonts/web/woff
woffs=$(ls fonts/static/*/*.woff)
for woff in $woffs; do
    mv $woff fonts/web/woff/$(basename $woff)
done



cd sources

echo "Generating VFs"
mkdir -p ../fonts/variable
fontmake --keep-overlaps -g Anybody.glyphs -o variable --output-path ../fonts/variable/Anybody[slnt,wdth,wght].ttf

rm -rf master_ufo/ instance_ufo/


cd ../fonts/variable

woff2_compress Anybody[slnt,wdth,wght].ttf

cd ..



echo "Post processing VF"
vf=../fonts/variable/Anybody[slnt,wdth,wght].ttf
gftools fix-dsig -f $vf;
gftools fix-nonhinting $vf $vf.fix;
mv "$vf.fix" $vf;



# Strip MVAR
ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
rtrip=$(basename -s .ttf $vf)
new_file=../fonts/variable/$rtrip.ttx;
rm $vf;
ttx $new_file
rm $new_file


rm ../fonts/variable/*gasp.ttf

echo "Complete!"
