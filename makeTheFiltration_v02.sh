#!/bin/bash
# vim: set ts=4 expandtab sw=4:

#mv graph_tools/twitter.db -t ../filtration_v02

echo "Compiling the C files for the filtration"
echo ""
cd filtration_v02/

gcc enumerate_nodes_edges_by_integers.c   -o enumerate_nodes_edges_by_integers

echo "Generating all possible paths of dim 1 and 2" 
echo ""
perl insert_all_possible_edges.pl

echo "Generating nodes.txt and edges.txt and pathDim2.txt" 
echo "Each edge is followed by its weight"
echo ""
sqlite3 twitter.db < generate_nodes_and_edges_and_pathsDim2_to_txt.sql


echo "Enumerating each node in a convenient way: 0, 1, 2, 3, ..."
echo ""
./enumerate_nodes_edges_by_integers

mv nodes.txt nodes_orignal_file.txt
rm edges.txt

mv nodes_enumerated.txt nodes.txt
mv edges_enumerated.txt edges.txt

mv pathDim1_enumerated.txt all_regular_paths_dimension_1.txt
mv pathDim2_enumerated.txt all_regular_paths_dimension_2.txt

mkdir data
mv *txt -t data/
mv data/ -t ../pph_in_C_v02/

rm enumerate_nodes_edges_by_integers

mv twitter.db -t ../
echo ""
echo "Everything DONE."
printf "Finishing "
for t in {1..10..1}
do
	sleep 1
	printf "."
done
echo""
