#!/bin/sh

gnuplot pphPlots.gpi 2> /dev/null

convert -rotate 90 pph0_BarCode.png pph0_BarCode.png
convert -rotate 90 pph1_BarCode.png pph1_BarCode.png
