#!/bin/bash

sqlite3 twitter.db < influencers.sql
sqlite3 twitter.db < convincers.sql

for file in *.dot 
do
    sfdp $file -Tpng -o ${file//dot/png}
done
