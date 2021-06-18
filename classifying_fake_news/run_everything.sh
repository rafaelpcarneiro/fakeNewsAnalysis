#!/bin/bash

echo "Running dictionary.pl"
./dictionary.pl

echo "Inserting all words into words.txt"
for file in `ls -1 *txt`
do
	cat $file >> words.txt
done

ls *.txt -1| grep -P "\d+\.txt"|xargs rm -f
    
echo "Reading words.txt to twitter.db"
sqlite3 twitter.db < create_dict.sql

./insert_words_on_database.pl

echo "Sampling now"
# sampling now
./sampling.pl
