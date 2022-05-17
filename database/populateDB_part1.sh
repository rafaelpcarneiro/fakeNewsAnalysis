#!/bin/bash
# Here I will populate the relational database, called twitter.db

sqlite3 < createTables.sql

rm log.txt 2> /dev/null
echo "Populating the database."
echo "Please do not turn off the laptop until the operation has finished"

echo ""
echo ""
sleep 5
echo "Starting now..."
sleep 3


day=`grep -P "^[^#]" time.txt| grep -P "^[^ ]+"| sed -n 1p`

for file in `ls $day/ |sort -V`
do
	echo "$file" >> log.txt
	./insertTweetsAndUsersToDB.pl "$day/$file" >>log.txt
	echo "========================================================" >> log.txt
	echo "Scanning file $file"
done

echo "All files have been scanned. Check the log file to see if"
echo "everything went fine. 0 means that nothing wrong occurred during"
echo "the scanning."

