#!/bin/bash
# Here I will populate the relational database, called twitter.db, with all tweets
# that I have stored in the folder 2021-03-25. 

total=`ls -1 2021-03-25/|wc -l`
iter=1
clear
for file in `ls -1 -t -r 2021-03-25/`
do
	echo "Populating the database."
	echo "Please do not turn off the laptop until the operation has finished"
	
	echo ""
	echo ""

	./insertTweetsAndUsersToDB.pl $file
	perc=`bc <<< "$iter * 100 / $total"`
	echo "Percentage of scanned files: $perc"
	iter=$((iter+1))
	clear
done

