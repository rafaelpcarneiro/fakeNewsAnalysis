#/bin/sh

# Firstly, we must set the sample database
sqlite3            < set_sampleDB.sql
sqlite3 twitter.db < take_a_sample_using_influence_as_weight.sql

perl create_filtration_dim_1.pl

sqlite3 twitter.db < populate_sampleDB.sql

sqlite3 sample.db  < generate_the_filtration_data.sql

gcc enumerate_nodes_edges_from_filtration_to_integers.c -o enumerate_nodes_edges_from_filtration_to_integers

chmod 700  enumerate_nodes_edges_from_filtration_to_integers
./enumerate_nodes_edges_from_filtration_to_integers

sqlite3 twitter.db < clean_twitterDB.sql
