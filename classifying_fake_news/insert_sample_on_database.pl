#!/bin/perl
# vim: set foldmethod=marker ts=4 expandtab sw=4:

#|--- Documentation {{{1
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;

use DBI;                   # database

use utf8;
use open ':encoding(utf8)';
binmode(STDOUT, ":utf8");
binmode(STDIN, ":encoding(utf8)");
#1}}}

#|--- MAIN {{{1

#|--- Variables {{{2

# Relational Database
my $dbfile = 'twitter.db';

my $dsn = "dbi:SQLite:dbname=$dbfile";
my $user = '';
my $password ='';
my $dbh = DBI->connect ($dsn, $user, $password, {
	PrintError		 => 0,
	RaiseError		 => 1,
	AutoCommit		 => 1,
    sqlite_unicode   => 1,
	FetchHashKeyName => 'NAME_lc',
});

my $sql_insert;

# FIle header for the file words.txt
my $fh;

# variables related with the content of words.txt
my $tweet_id;
my $is_tweet_id_unreliable;

# END VARIABLES 2}}}

#|--- Inserting words into the dictionary {{{2

$sql_insert  = $dbh->prepare ("UPDATE dictionary
                               SET was_this_tweet_id_sampled                = ?,
                                   if_tweet_id_was_sampled_is_it_unreliable = ?
                               WHERE tweet_id = ?");

open $fh, '<', 'naiveBayes_data.sample'
    or die "Couldn't open the file naiveBayes_data.sample";

<$fh>; #ignore the first line.
while (<$fh>) {
    ($tweet_id, $is_tweet_id_unreliable) = split (/[\t ]+/, $_);
    $sql_insert->execute (1, $is_tweet_id_unreliable, $tweet_id);
}
                                                    
# END Inserting words into the dictionary 2}}}

# END MAIN 1}}} 

