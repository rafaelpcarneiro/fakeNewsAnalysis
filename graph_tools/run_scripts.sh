#!/bin/bash

sqlite3 twitter.db < root_view.sql
sqlite3 twitter.db < edges.sql

./root_view.sql
./edges.pl
