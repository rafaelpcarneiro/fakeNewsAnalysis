#!/bin/bash
# vim: set ts=4 expandtab sw=4:
cp ~/twitter.db -t graph_tools/

echo "Creating the tree structure over the database (convinience only)"
echo ""
#sqlite3 twitter.db ".read root_view.sql"
#perl nodes_tree.pl

#sqlite3 twitter.db ".read edges.sql"
#perl edges.pl
mv graph_tools/twitter.db -t ../filtration

echo "Compiling the C files for the filtration"
echo ""
cd filtration/

gcc branches.c                            -o my_branch
gcc enumerate_nodes_edges_by_integers.c   -o enumerate_nodes_edges_by_integers
gcc create_paths_dim_1_and_2.c            -o create_paths_dim_1_and_2 
gcc eliminate_repetitions_paths_dim_1_2.c -o eliminate_repetitions_paths_dim_1_2

echo "Generating nodes.txt and edges.txt that will provide info to branch.c"
echo "Each edge weight is given by the time taken to the tweet son get born"
echo ""
#sqlite3 twitter.db < generate_nodes_and_edges_to_txt.sql
sqlite3 twitter.db < generate_nodes_and_edges_to_txt_filtered_by_time.sql


echo "Enumerating each node in a convenient way: 0, 1, 2, 3, ..."
echo ""
./enumerate_nodes_edges_by_integers

mv nodes.txt nodes_orignal_file.txt
rm edges.txt

mv nodes_enumerated.txt nodes.txt
mv edges_enumerated.txt edges.txt

echo "Now it is time to check for all branches of our tree"
echo ""
./my_branch > all_branches.txt

wc -l all_branches.txt |grep -o -P "\d*\s" > all_branches_tmp.txt
cat all_branches.txt     >> all_branches_tmp.txt
cat all_branches_tmp.txt >  all_branches.txt
rm all_branches_tmp.txt

echo "Now we check for all regular paths of dimension 1"
echo ""
./create_paths_dim_1_and_2 1 > all_regular_paths_dimension_1.txt

wc -l all_regular_paths_dimension_1.txt |grep -o -P "\d*\s" > all_regular_paths_dimension_1_tmp.txt
cat all_regular_paths_dimension_1.txt     >> all_regular_paths_dimension_1_tmp.txt
cat all_regular_paths_dimension_1_tmp.txt >  all_regular_paths_dimension_1.txt
rm all_regular_paths_dimension_1_tmp.txt

echo "And, finally, all regular paths of dimension 2"
echo ""
./create_paths_dim_1_and_2 2 > all_regular_paths_dimension_2.txt

wc -l all_regular_paths_dimension_2.txt |grep -o -P "\d*\s" > all_regular_paths_dimension_2_tmp.txt
cat all_regular_paths_dimension_2.txt     >> all_regular_paths_dimension_2_tmp.txt
cat all_regular_paths_dimension_2_tmp.txt >  all_regular_paths_dimension_2.txt
rm all_regular_paths_dimension_2_tmp.txt

echo "Now we need to check whether or not there are repetead paths"
echo "In case positive, repetitions shall be deleted"
echo ""
./eliminate_repetitions_paths_dim_1_2

check_diff=`diff -q all_regular_paths_dimension_1.txt all_regular_paths_dimension_1_w_rep.txt|
    grep "differ"`

if [ -n "$check_diff" ]
then
	echo "There are repetitions and we need to purge them from the file"
	echo "all_regular_paths_dimension_1.txt"
	wc -l all_regular_paths_dimension_1_w_rep.txt |grep -o -P "\d*\s" >\
        all_regular_paths_dimension_1.txt
	cat all_regular_paths_dimension_1_w_rep.txt >> all_regular_paths_dimension_1.txt
	rm all_regular_paths_dimension_1_w_rep.txt
else
	echo "There are no repetitions. Keep the file all_regular_paths_dimension_1.txt"
	rm all_regular_paths_dimension_1_w_rep.txt
fi

check_diff=`diff -q all_regular_paths_dimension_2.txt all_regular_paths_dimension_2_w_rep.txt|
    grep "differ"`

if [ -n "$check_diff" ]
then
	echo "There are repetitions and we need to purge them from the file"
    echo "all_regular_paths_dimension_2.txt"
	wc -l all_regular_paths_dimension_2_w_rep.txt |grep -o -P "\d*\s" >\
        all_regular_paths_dimension_2.txt
	cat all_regular_paths_dimension_2_w_rep.txt >> all_regular_paths_dimension_2.txt
	rm all_regular_paths_dimension_2_w_rep.txt
else
	echo "There are no repetitions. Keep the file all_regular_paths_dimension_2.txt"
	rm all_regular_paths_dimension_2_w_rep.txt
fi

mkdir data
mv *txt -t data/
mv data/ -t ../pph_in_C/

rm my_branch
rm enumerate_nodes_edges_by_integers
rm create_paths_dim_1_and_2 
rm eliminate_repetitions_paths_dim_1_2

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
