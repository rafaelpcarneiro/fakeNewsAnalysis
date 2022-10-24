#/bin/bash
# -----------------------------------------------------------
#    This script is responsible for generating the whole
#    filtration
#
# Parameters: $1 -> BIN_EDGE_MIN
#             $2 -> BIN_EDGE_LENGTH_MIN
# -----------------------------------------------------------
#
#
# Weight function weight: {e an edge for the graph G} -> R:
#     The expected time that users take to answer each other
# 

fileToCompile="enumerate_nodes_edges_from_filtration_to_integers.c"


echo ""
echo "Selecting edges inside a time interval && calculating its weights"
echo ""

# Setting the variables of the SQL script take_a_sample_using_time_as_weight.sql
sed "s/<BIN_EDGE_MIN>/$1/" select_edges_inside_a_time_interval.template > \
    select_edges_inside_a_time_interval.sql

sed -i "s/<BIN_EDGE_LENGTH_MIN>/$2/"    select_edges_inside_a_time_interval.sql

# Firstly, we must set the sample database
sqlite3            < set_graph_of_a_time_intervalDB.sql
sqlite3 twitter.db < select_edges_inside_a_time_interval.sql

perl create_filtration_dim_1.pl

sqlite3 twitter.db < populate_graph_of_a_time_interval.sql

sqlite3 sample.db  < generate_the_filtration_data.sql

gcc -Wall -Wextra  -Werror -ansi -pedantic -O3  $fileToCompile -o ${fileToCompile%.c}

echo "All filtration is complete"
echo ""

chmod 700  ${fileToCompile%.c}
./${fileToCompile%.c}


## cleaning all directory from auxiliary files created in the meantime
## Also cleaning data created that is not necessary anymore
sqlite3 twitter.db < clean_twitterDB.sql
rm nodes.txt edges.txt pathDim2.txt
rm ${fileToCompile%.c}


sleep 5

#=== RESULTS ================================================================
# All calculations are done and all files regarding the filtration
# are stored inside data/
#
# Obs: the file data/graph_of_a_time_interval.db is the database containing
# the graph obtained applying the condtraint of all tweets being contained
# on a time interval I
#============================================================================

[ -d 'data/' ] || mkdir data
[ -d 'data/' ] && rm    data/* 2> /dev/null

mv  edges_enumerated.txt edges.txt
mv  nodes_enumerated.txt nodes.txt

mv *txt       -t data/
mv graph_of_a_time_interval.db  -t data/
#mv twitter.db -t ../
