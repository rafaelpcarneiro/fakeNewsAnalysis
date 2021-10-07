#!/bin/bash
# Here I will populate the relational database, called twitter.db, with all tweets
# that I have stored in the folder 2021-03-25. 

sqlite3 < createTables.sql

rm log.txt
echo "Populating the database."
echo "Please do not turn off the laptop until the operation has finished"

echo ""
echo ""
sleep 5
echo "Starting now..."
sleep 3

for file in `ls 2021-03-25/ |sort -V`
do
	echo "$file" >> log.txt
	./insertTweetsAndUsersToDB.pl "2021-03-25/$file" >>log.txt
	echo "========================================================" >> log.txt
	echo "Scaning file $file"
done

echo "All files have been scanned. Check the log file to see if"
echo "everything went fine. 0 means that nothing wrong occurred during"
echo "the scanning."

