#!/bin/bash

sqlite3 twitter.db < root_view.sql
sqlite3 twitter.db < edges.sql

./nodes_tree.pl
./edges.pl
