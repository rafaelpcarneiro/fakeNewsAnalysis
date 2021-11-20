#!/usr/bin/perl
# vim: foldmethod=marker:

#|--- Modules {{{1
use warnings;
use strict;
use DBI;
#1}}}

#|--- MAIN {{{1

#|--- Variables {{{2

# Relational Database
my $dbfile = 'twitter.db';

my $dsn = "dbi:SQLite:dbname=$dbfile";
my $user = '';
my $password ='';
my $dbh = DBI->connect ($dsn, $user, $password, {
    PrintError       => 0,
    RaiseError       => 1,
    AutoCommit       => 1,
    sqlite_unicode   => 1,
    FetchHashKeyName => 'NAME_lc',
});

my $path_distance;

my $sql_insert;
my $columns_added;

my $sql_how_many_inserted;

# END VARIABLES 2}}}

#|--- Checking for the nodes of the graph by each generation {{{2

#|--- Declaring SQL commands to be executed at each generation {{{3
$sql_insert = $dbh->prepare (
                "INSERT OR IGNORE INTO paths_xy_SAMPLE
                 SELECT L.from_tweet_id,        R.to_tweet_id,
                        L.from_author_tweet_id, R.to_author_tweet_id,
                        ?
                 FROM 
                    (SELECT * 
                     FROM paths_xy_SAMPLE
                     WHERE path_distance = ?
                           AND
                           from_author_tweet_id != -1) AS L
                 INNER JOIN
                    (SELECT *
                     FROM paths_xy_SAMPLE
                     WHERE path_distance = 1
                           AND
                           from_author_tweet_id != -1) AS R
                 ON L.to_author_tweet_id = R.from_author_tweet_id");

$sql_how_many_inserted = $dbh->prepare (
                "SELECT DISTINCT changes() FROM paths_xy_SAMPLE");

# 3}}}

#|--- Executing SQL commands at each generation {{{3
$path_distance = 1;
do {
    print "Path distance = $path_distance\n";

    $sql_insert->execute ($path_distance + 1, $path_distance);

    $sql_how_many_inserted->execute ();
    ($columns_added) = $sql_how_many_inserted->fetchrow_array;

    ++$path_distance;
} while ($columns_added > 0);
# 3}}}

# 2}}}

# END MAIN 1}}} 

