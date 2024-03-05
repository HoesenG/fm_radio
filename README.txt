

Quick build:

g++ src/fm_radio.cpp src/audio.cpp src/main.cpp -o fm_radio
./fm_radio test/usrp.dat

Make:
make all        - compiles, dumps data and trims it
make radio      - compiles
make all_data   - dumps data and trims it
make bin        - dumps data
make hex        - converts bin to hex
make trim       - trims hex file
make clean      - removes .txt .bin