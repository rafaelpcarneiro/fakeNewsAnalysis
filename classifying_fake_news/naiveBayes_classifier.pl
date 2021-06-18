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

#|--- Functions {{{1
sub estimating_probabilities {
}
# END Functions 1}}}


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

my $sql_tweets_to_classify;
my $sql_words_sampled;

my $sql_insert_tweets_naiveBayes;

# variables related with the words sampled
my @words;

my $tweet_id;
my @tweets_to_classify;

my $is_tweet_id_unreliable;

# END VARIABLES 2}}}

#|--- Get all info necessary from twitter.db {{{2

$sql_tweets_to_classify = $dbh->prepare ("SELECT tweet_id
                                          FROM dictionary
                                          WHERE was_this_tweet_id_sampled = 0
                                          GROUP BY tweet_id");

$sql_words_sampled      = $dbh->prepare ("SELECT word_found_on_tweet_id
                                          FROM dictionary
                                          WHERE was_this_tweet_id_sampled = 1
                                          GROUP BY word_found_on_tweet_id");

$sql_insert_tweets_naiveBayes = $dbh->prepare ("INSERT INTO naiveBayes (tweet_id)
                                                VALUES (?)");
#END Get all info necessary from twitter.db 2}}}

#|--- Calculating all probabilities {{{2
                                                    
$sql_tweets_to_classify->execute ();
while (($tweet_id) = $sql_tweets_to_classify->fetchrow_array) {
    $sql_insert_tweets_naiveBayes->execute ($tweet_id);
    push @tweets_to_classify, $tweet_id;
}
#END Calculating all probabilities 2}}}

# END MAIN 1}}} 

