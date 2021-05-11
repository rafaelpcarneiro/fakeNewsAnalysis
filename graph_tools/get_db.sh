#cp ~/twitter.db -t ./
#sqlite3 twitter.db ".read root_view.sql"
#perl nodes_tree.pl
sqlite3 twitter.db ".read paths.sql"
#perl paths_xy.pl
perl paths_xyz.pl
