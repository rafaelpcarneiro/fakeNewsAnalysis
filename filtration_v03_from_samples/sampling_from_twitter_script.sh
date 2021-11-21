#/bin/sh

fileToCompile="enumerate_nodes_edges_from_filtration_to_integers.c"

echo "-----------------------------------------------------------"
echo "   This script is responsible to take a sample from the"
echo "   User interaction graph and to generate its filtration"
echo ""
echo "Parameter: Sample equivalent to 40% of the whole database"
echo "-----------------------------------------------------------"
echo ""

echo "What weight matrix should I use to calculate the distance:"
echo "[1] weight matrix given by the repetitions of edges"
echo "[2] The expected time that users take to answer each other"
echo "[3] Trivial weight -- each edge has weight = 1"
echo ""
echo -n "Your answer (type in 1 or 2 or 3): "
read answer

# Firstly, we must set the sample database
sqlite3            < set_sampleDB.sql
if [ $answer -eq 1 ]
then 
    sqlite3 twitter.db < take_a_sample_using_edges_repetition_as_weight.sql
    answerStr="weight matrix given by the repetitions of edges"
elif [ $answer -eq 2 ]
then 
    sqlite3 twitter.db < take_a_sample_using_time_as_weight.sql
    answerStr="weight matrix given by expected time of answers"
else
    sqlite3 twitter.db < take_a_sample_using_trivial_weight.sql
    answerStr="Trivial weight matrix"
fi

perl create_filtration_dim_1.pl

sqlite3 twitter.db < populate_sampleDB.sql

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

echo ""
echo "=== RESULTS ================================================================"
echo " All calculations are done and all files regarding the filtration"
echo " are stored inside data/"
echo ""
echo " Weight Matrix -> $answerStr"
echo " Obs: the file data/sample.db is the database containing the sample obtained"
echo " as well its filtration"
echo "============================================================================"

[ -d 'data/' ] || mkdir data
[ -d 'data/' ] && rm    data/* 2> /dev/null

mv  edges_enumerated.txt edges.txt
mv  nodes_enumerated.txt nodes.txt

mv *txt       -t data/
mv sample.db  -t data/
#mv twitter.db -t ../
