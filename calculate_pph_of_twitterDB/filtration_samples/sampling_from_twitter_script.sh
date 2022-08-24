#/bin/bash

# -----------------------------------------------------------
#    This script is responsible for taking a sample from a 
#    Barabasi graph and to generate its filtration
# -----------------------------------------------------------

./filtration.py  --sampleSize $1
./enumerate_nodes_edges_from_filtration_to_integers

[ -d 'data/' ] || mkdir data
[ -d 'data/' ] && rm    data/* 2> /dev/null

mv *txt       -t data/
