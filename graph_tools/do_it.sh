cp ~/twitter.db -t ./

#sqlite3 twitter.db ".read root_view.sql"
#perl nodes_tree.pl

#sqlite3 twitter.db ".read edges.sql"
#perl edges_xy.pl

echo "Compiling the C files"
echo ""
gcc branches.c -o my_branch
gcc enumerate_nodes_edges_by_integers.c -o enumerate_nodes_edges_by_integers
gcc create_paths_dim_2_and_3.c -o create_paths_dim_2_and_3 


echo "Generating nodes.txt and edges.txt that will provide info to branch.c"
echo ""
sqlite3 twitter.db < generate_nodes_txt.sql
sqlite3 twitter.db < generate_edges_txt.sql


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
cat all_branches.txt >> all_branches_tmp.txt
cat all_branches_tmp.txt > all_branches.txt
rm all_branches_tmp.txt

echo "Now we check for all regular paths of dimension 2"
echo ""
./create_paths_dim_2_and_3 2 > all_regular_paths_dimension_2.txt

echo "And, finally, all regular paths of dimension 3"
echo ""
./create_paths_dim_2_and_3 3 > all_regular_paths_dimension_3.txt
