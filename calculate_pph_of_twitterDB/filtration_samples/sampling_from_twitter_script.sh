#/bin/bash

# -----------------------------------------------------------
#    This script is responsible to take a sample from the
#    User interaction graph and to generate its filtration
# 
# Parameters: $1 -> DATE_START
#             $2 -> DATE_END
#             $3 -> SAMPLE_SIZE
# -----------------------------------------------------------
# 
#
# Weight matrix used to calculate the distance:
#     The expected time that users take to answer each other
# 

fileToCompile="enumerate_nodes_edges_from_filtration_to_integers.c"


echo ""
echo "Taking a sample of twitter.db to calculate the persistent homology..."
echo ""

# Setting the variables of the SQL script take_a_sample_using_time_as_weight.sql
sed "s/<DATE_START>/$1/"     take_a_sample_using_time_as_weight_model.sql > \
                             take_a_sample_using_time_as_weight.sql
sed -i "s/<DATE_END>/$2/"    take_a_sample_using_time_as_weight.sql
sed -i "s/<SAMPLE_SIZE>/$3/" take_a_sample_using_time_as_weight.sql

# Firstly, we must set the sample database
sqlite3            -vfs unix-none < set_sampleDB.sql
sqlite3 twitter.db -vfs unix-none < take_a_sample_using_time_as_weight.sql

perl create_filtration_dim_1.pl

sqlite3 twitter.db -vfs unix-none < populate_sampleDB.sql

sqlite3 sample.db  -vfs unix-none < generate_the_filtration_data.sql

gcc -Wall -Wextra  -Werror -Wno-long-long -ansi -pedantic -O3  $fileToCompile -o ${fileToCompile%.c}

echo "All filtration is complete"
echo ""

chmod 700  ${fileToCompile%.c}
./${fileToCompile%.c}


## cleaning all directory from auxiliary files created in the meantime
## Also cleaning data created that is not necessary anymore
sqlite3 twitter.db -vfs unix-none < clean_twitterDB.sql
rm nodes.txt edges.txt pathDim2.txt
rm ${fileToCompile%.c}


sleep 5

#=== RESULTS ================================================================
# All calculations are done and all files regarding the filtration
# are stored inside data/
#
# Obs: the file data/sample.db is the database containing the sample obtained
# as well its filtration
#============================================================================

[ -d 'data/' ] || mkdir data
[ -d 'data/' ] && rm    data/* 2> /dev/null

mv  edges_enumerated.txt edges.txt
mv  nodes_enumerated.txt nodes.txt

mv *txt       -t data/
#mv sample.db  -t data/
rm sample.db  
#mv twitter.db -t ../
