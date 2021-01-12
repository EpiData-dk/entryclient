#/bin/bash

lazbuild -B epidataentryclient.lpi
strip epidataentryclient

lazbuild -B --bm=win64 epidataentryclient.lpi
strip epidataentryclient.exe

