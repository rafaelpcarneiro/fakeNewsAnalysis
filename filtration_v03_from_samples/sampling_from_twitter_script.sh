#/bin/sh

fileToCompile="enumerate_nodes_edges_from_filtration_to_integers.c"

echo "-----------------------------------------------------------"
echo "   This script is responsible to take a sample from the"
echo "   User interaction graph and to generate its filtration"
echo ""
echo "Parameter: Sample equivalent to 40% of the whole database"
echo "-----------------------------------------------------------"
echo ""

# Firstly, we must set the sample database
sqlite3            < set_sampleDB.sql
sqlite3 twitter.db < take_a_sample_using_influence_as_weight.sql

perl create_filtration_dim_1.pl

sqlite3 twitter.db < populate_sampleDB.sql

sqlite3 sample.db  < generate_the_filtration_data.sql

gcc -Wall -Wextra  -Werror -ansi -pedantic -O3  $fileToCompile -o ${fileToCompile%.c}

echo "All filtration is complete - regarding the sample"
echo ""

chmod 700  ${fileToCompile%.c}
./${fileToCompile%.c}


mv  edges_enumerated.txt edges.txt
mv  nodes_enumerated.txt nodes.txt


## cleaning all directory from auxiliary files created in the meantime
## Also cleaning data created that is not necessary anymore
sqlite3 twitter.db < clean_twitterDB.sql
rm nodes.txt edges.txt pathDim2.txt
rm ${fileToCompile%.c}


sleep 5

echo ""
echo "=== RESULTS ================================================================"
echo " All calculations are done and all files regarding the filtration"
echo " are stored inside data/"
echo " Obs: the file data/sample.db is the database containing the sample obtained"
echo " as well its filtration"
echo "============================================================================"

[ -d 'data/' ] || mkdir data
[ -d 'data/' ] && rm    data/*
mv *txt       -t data/
mv sample.db  -t data/
#mv twitter.db -t ../
