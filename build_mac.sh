#!/bin/bash

clean_build_dirs () {
    [ -d ./__pycache__ ] && rm -rf __pycache__
    [ -d ./build ] && rm -rf ./build
    [ -d ./venv ] && rm -rf ./venv
    [ -f ./onthespot_mac.spec ] && rm ./onthespot_mac.spec
    [ -f ./onthespot_mac_ffm.spec ] && rm ./onthespot_mac_ffm.spec
    [ -d ./dist/onthespot_mac ] && rm -rf ./dist/onthespot_mac
}


echo "========= OnTheSpot MacOS Build Script ==========="
echo " => Cleaning up !"
[ -d ./dist/onthespot_mac.app ] && rm -rf ./dist/onthespot_mac.app
[ -d ./dist/onthespot_mac_ffm.app ] && rm -rf ./dist/onthespot_mac_ffm.app
clean_build_dirs

echo " => Creating virtual env."
python3 -m venv venv

echo " => Switching to virtual env."
source ./venv/bin/activate

echo " => Installing 'pyinstaller' via pip..."
pip install pyinstaller

echo " => Installing dependencies to venv with pip..."
pip install -r requirements.txt

if [ -f "ffbin_mac/ffmpeg" ]; then
    echo " => Found 'ffbin_mac' directory and ffmpeg binary.. Using ffmpeg binary append mode "
    pyinstaller --windowed \
                --hidden-import="zeroconf._utils.ipaddress" \
                --hidden-import="zeroconf._handlers.answers" \
                --add-data="src/onthespot/gui/qtui/*.ui:onthespot/gui/qtui" \
                --add-data="src/onthespot/resources/icons/*.png:onthespot/resources/icons" \
                --add-data="src/onthespot/resources/themes/*.qss:onthespot/resources/themes" \
                --add-data="src/onthespot/resources/translations/*.qm;onthespot/resources/translations" \
                --add-binary="ffbin_mac/*:onthespot/bin/ffmpeg" \
                --paths="src/onthespot" \
                --name="onthespot_mac_ffm" \
                --icon="src/onthespot/resources/onthespot.png" \
                src/portable.py
else
    echo " => Building to use ffmpeg binary from system... "
    pyinstaller --windowed \
                --hidden-import="zeroconf._utils.ipaddress" \
                --hidden-import="zeroconf._handlers.answers" \
                --add-data="src/onthespot/gui/qtui/*.ui:onthespot/gui/qtui" \
                --add-data="src/onthespot/resources/icons/*.png:onthespot/resources/icons" \
                --add-data="src/onthespot/resources/themes/*.qss:onthespot/resources/themes" \
                --add-data="src/onthespot/resources/translations/*.qm;onthespot/resources/translations" \
                --paths="src/onthespot" \
                --name="onthespot_mac" \
                --icon="src/onthespot/resources/onthespot.png" \
                src/portable.py
fi
echo " => Setting executable permissions.. "
[ -f ./dist/onthespot_mac ] && chmod +x ./dist/onthespot_mac &>./build_nix.log
[ -f ./dist/onthespot_mac_ffm ] && chmod +x ./dist/onthespot_mac_ffm &>./build_nix.log

echo " => Cleaning .. "
clean_build_dirs

echo " => Done "
