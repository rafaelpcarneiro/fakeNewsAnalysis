#!/bin/bash


./database/populateDB_part1.sh
mv /database/twitter.db -t graph_tools/
./graph_tools/run_scripts.sh
