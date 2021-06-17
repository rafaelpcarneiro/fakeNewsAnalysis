#!/bin/perl
# vim: set foldmethod=marker ts=4 expandtab sw=4:

#|--- Documentation {{{1
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;

use DBI;                   # database
##binmode(STDOUT, ":utf-8"); #utf8 chars
##binmode(STDIN, ":utf-8"); #utf8 chars
#1}}}

#|--- Functions {{{1
# 1}}}

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
	FetchHashKeyName => 'NAME_lc',
});

my $sql_insert;

# FIle header for the file words.txt
my $fh;

# variables related with the content of words.txt
my $tweet_id;
my $word;
my $word_counter;

# END VARIABLES 2}}}

#|--- Inserting words into the dictionary {{{2

$sql_insert  = $dbh->prepare ("INSERT INTO dictionary(
                                  tweet_id,				         
                                  word_found_on_tweet_id,		     
                                  word_counter_considering_tweet_id
                               )
                               VALUES (?,?,?)");

open $fh, '<', 'words.txt'
    or die "Couldn't open the file words.txt";

while (<$fh>) {
    ($tweet_id, $word, $word_counter) = split (/\t/, $_);
    $sql_insert->execute ($tweet_id, $word, $word_counter);
    print "$tweet_id\n";
}
                                                    
# END Inserting words into the dictionary 2}}}

# END MAIN 1}}} 

