cp ~/twitter.db -t ./

#sqlite3 twitter.db ".read root_view.sql"
#perl nodes_tree.pl

#sqlite3 twitter.db ".read edges.sql"
#perl edges_xy.pl

sqlite3 twitter.db < generate_nodes_txt.sql
sqlite3 twitter.db < generate_edges_txt.sql


gcc branches.c -o my_branch
gcc enumerate_nodes_edges_by_integers.c -o enumerate_nodes_edges_by_integers

./enumerate_nodes_edges_by_integers
rm nodes.txt edges.txt

mv nodes_enumerated.txt nodes.txt
mv edges_enumerated.txt edges.txt
