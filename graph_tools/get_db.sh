cp ~/twitter.db -t ./
sqlite3 twitter.db ".read root_view.sql"
perl nodes_tree.pl
