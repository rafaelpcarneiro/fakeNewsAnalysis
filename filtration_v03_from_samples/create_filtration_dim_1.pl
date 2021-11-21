#!/usr/bin/perl
# vim: foldmethod=marker:

#|--- Modules 
use warnings;
use strict;
use DBI;

#|--- MAIN 

#|--- Variables

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


# Declaring SQL commands to be executed generating all possible paths
# In another words, SQL commands that will allow us to walk on the graph

# NOTE INSERT OR IGNORE if highly important so we won't get ourselves
# into loops inside the graph. PRIMARY KEYS are here to save us =)

$sql_insert = $dbh->prepare (
                "INSERT OR IGNORE INTO paths_xy_SAMPLE
                 SELECT L.from_tweet_id,        R.to_tweet_id,
                        L.from_author_tweet_id, R.to_author_tweet_id,
                        ?,
                        L.path_weight + R.path_weight
                 FROM 
                    (SELECT * 
                     FROM paths_xy_SAMPLE
                     WHERE path_length = ?) AS L
                 INNER JOIN
                    (SELECT *
                     FROM paths_xy_SAMPLE
                     WHERE path_length = 1) AS R
                 ON L.to_author_tweet_id = R.from_author_tweet_id");

$sql_how_many_inserted = $dbh->prepare (
                "SELECT DISTINCT changes() FROM paths_xy");


# Now lets walk on the graph - step by step
$path_distance = 1;
do {
    print "Path distance = $path_distance\n";

    $sql_insert->execute ($path_distance + 1, $path_distance);

    $sql_how_many_inserted->execute ();
    ($columns_added) = $sql_how_many_inserted->fetchrow_array;

    ++$path_distance;
} while ($columns_added > 0);
