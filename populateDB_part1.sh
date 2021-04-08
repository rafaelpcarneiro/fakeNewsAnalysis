#!/bin/bash
# Here I will populate the relational database, called twitter.db, with all tweets
# that I have stored in the folder 2021-03-25. 

for file in `ls -1 -t -r 2021-03-25/`
do
	echo "Populating the database."
	echo "Please do not turn off the laptop until the operation has finished"
	
	echo ""
	echo ""

	echo "$file log-> $?" >> log.txt
	echo "$file log-> $?"
	./insertTweetsAndUsersToDB.pl "2021-03-25/$file"
done

