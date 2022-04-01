#/bin/sh

fileToCompile="enumerate_nodes_edges_from_filtration_to_integers.c"


echo ""
echo "Calculating the filtration of a sample from twitter.db..."
echo ""

# Setting the variables of the SQL script: take_a_sample_using_time_as_weight.sql
sed "s/<DATE_START>/$1/"  take_a_sample_using_time_as_weight_model.sql > take_a_sample_using_time_as_weight.sql
sed -i "s/<DATE_END>/$2/"    take_a_sample_using_time_as_weight.sql 
sed -i "s/<SAMPLE_SIZE>/$3/" take_a_sample_using_time_as_weight.sql

# Firstly, we must set the sample database
sqlite3            < set_sampleDB.sql
sqlite3 twitter.db < take_a_sample_using_time_as_weight.sql

perl create_filtration_dim_1.pl

sqlite3 twitter.db < populate_sampleDB.sql

sqlite3 sample.db  < generate_the_filtration_data.sql

gcc -Wall -Wextra  -Werror -ansi -pedantic -O3  $fileToCompile -o ${fileToCompile%.c}

echo "All filtration is complete ..."
echo ""

chmod 700  ${fileToCompile%.c}
./${fileToCompile%.c}


## cleaning all directory from auxiliary files created in the meantime
## Also cleaning data created that is not necessary anymore
sqlite3 twitter.db < clean_twitterDB.sql
rm nodes.txt edges.txt 
rm ${fileToCompile%.c}


sleep 5


[ -d 'data/' ] || mkdir data
[ -d 'data/' ] && rm    data/* 2> /dev/null

mv  edges_enumerated.txt edges.txt
mv  nodes_enumerated.txt nodes.txt

mv *txt       -t data/
mv sample.db  -t data/
#mv twitter.db -t ../