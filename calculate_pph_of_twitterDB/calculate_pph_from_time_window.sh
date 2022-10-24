#!/bin/bash
#
# Parameters
#     $1 == the graph to be analyzed == $graph

graph=$1

cp -r filtration/ filtration_$graph

# Compile pph.c
cd ../pph_in_C                                                                      
make                                                                                
make clean    

mv pph_prog -t ../calculate_pph_of_twitterDB/filtration_$graph

cd ../calculate_pph_of_twitterDB

cd $graph/
BIN_EDGE_MIN=`head -n 1 time_window.txt`
BIN_EDGE_LENGTH_MIN=`tail -n 1 time_window.txt`
cd ../

cp $graph/twitter.db -t filtration_$graph/
cd filtration_$graph/


bash filtration_script.sh $BIN_EDGE_MIN $BIN_EDGE_LENGTH_MIN
./pph_prog
