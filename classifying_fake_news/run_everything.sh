#!/bin/bash

./dictionary.pl
for file in `ls -1 *txt`
do
	cat >> words.txt
done

ls !(words.txt) -1| grep -P ".*\.txt"|xargs rm -f

sqlite3 twitter.db < create_dict.sql

./insert_words_on_database.pl
