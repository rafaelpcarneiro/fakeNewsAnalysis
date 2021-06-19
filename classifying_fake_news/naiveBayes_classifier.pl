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

# variables related with the words sampled
my $tmp;
my $tmp1;
my $tmp0;
my $proportionalConstant;

my $word;
my $total_words_sampled;

my $tweet_id;

my $is_tweet_id_unreliable;

my $total_unreliable_tweets;
my $total_inconclusive_tweets;
my $total_sample;

my $numerator;
my $denominator;

my $prob0;  # p[W=word|Theta=0]
my $prob1;  # p[W=word|Theta=1] 
# END VARIABLES 2}}}

#|--- Get all info necessary from twitter.db {{{2

my $sql_tweets_to_classify = $dbh->prepare ("SELECT tweet_id
                                          FROM dictionary
                                          WHERE was_this_tweet_id_sampled = 0
                                          GROUP BY tweet_id");

my $sql_words_sampled      = $dbh->prepare ("SELECT word_found_on_tweet_id
                                          FROM dictionary
                                          WHERE was_this_tweet_id_sampled = 1
                                          GROUP BY word_found_on_tweet_id");

my $sql_amount_words_sampled = $dbh->prepare ("SELECT COUNT(word_found_on_tweet_id)
                                          FROM dictionary
                                          WHERE was_this_tweet_id_sampled = 1
                                          GROUP BY word_found_on_tweet_id");

my $sql_count_words        = $dbh->prepare ("SELECT COUNT(*)
                                          FROM dictionary
                                          WHERE (was_this_tweet_id_sampled = 1)
                                                AND
                                                (if_tweet_id_was_sampled_is_it_unreliable =?)
                                                AND
                                                (word_found_on_tweet_id = ?)");
                                            

my $sql_amount_unreliable_or_not_tweets  = $dbh->prepare (
                                         "SELECT COUNT(tweet_id)
                                          FROM dictionary
                                          WHERE (was_this_tweet_id_sampled = 1)
                                                AND
                                                (if_tweet_id_was_sampled_is_it_unreliable = ?)
                                          GROUP BY tweet_id");


my $sql_words_of_tweet     = $dbh->prepare ("SELECT word_found_on_tweet_id
                                          FROM dictionary
                                          WHERE tweet_id = ?");

my $sql_probabilities      = $dbh->prepare ("SELECT p[W=word|Theta=1], p[W=word|Theta=0]
                                          FROM probabilities
                                          WHERE word_sampled = ?");

my $sql_check_word_probabilities      = $dbh->prepare ("SELECT COUNT(*)
                                                        FROM probabilities
                                                        WHERE word_sampled = ?");


my $sql_insert_tweets_naiveBayes = $dbh->prepare ("INSERT INTO naiveBayes 
                                                VALUES (?,?,?,?)");

my $sql_insert_probabilities     = $dbh->prepare ("INSERT INTO probabilities
                                                VALUES (?,?,?)");
#END Get all info necessary from twitter.db 2}}}

#|--- Calculating all probabilities {{{2

# FIRST we will calculate the probability estimatives of
# a word being found in a tweet given that the tweet is unreliable
# or not

$sql_amount_unreliable_or_not_tweets->execute (1);
($total_unreliable_tweets)   = $sql_amount_unreliable_or_not_tweets->fetchrow_array;

$sql_amount_unreliable_or_not_tweets->execute (0);
($total_inconclusive_tweets) = $sql_amount_unreliable_or_not_tweets->fetchrow_array;
 
$total_sample                = $total_unreliable_tweets + $total_inconclusive_tweets;

$sql_amount_words_sampled->execute ();
($total_words_sampled) = $sql_amount_words_sampled->fetchrow_array;

$sql_words_sampled->execute ();
while (($word) = $sql_words_sampled->fetchrow_array) {

    $sql_count_words->execute (1, $word);
    ($numerator) = $sql_count_words->fetchrow_array;
    $prob1       = ($numerator + 1.0) / ($total_unreliable_tweets + $total_words_sampled);

    $sql_count_words->execute (0, $word);
    ($numerator) = $sql_count_words->fetchrow_array;
    $prob2       = ($numerator + 1.0) / ($total_inconclusive_tweets + $total_words_sampled);

    $sql_insert_probabilities->execute ($word, $prob1, $prob0);
}

# FINALLY,  lets classificate all tweets


$sql_tweets_to_classify->execute ();
while (($tweet_id) = $sql_tweets_to_classify->fetchrow_array) {

    $sql_words_of_tweet->excute ($tweet_id);
    $prob1 = 1.0;
    $prob2 = 1.0;
    while ( ($word) = $sql_words_of_tweet->fetchrow_array ){

        $sql_check_word_probabilities->execute ($word);
        ($tmp) = $sql_check_word_probabilities->fetchrow_array;

        if ($tmp == 0) {
            $prob1 *= 1.0 / ($total_unreliable_tweets + $total_words_sampled)
            $prob0 *= 1.0 / ($total_inconclusive_tweets + $total_words_sampled)
        }
        else {
            $sql_probabilities->execute ($word);
            ($tmp1, $tmp0) = $sql_probabilities->fetchrow_array;
            $prob1 *= $tmp1;
            $prob0 *= $tmp0;
        }
    }

    $prob1 *= ($total_unreliable_tweets   / $total_sample);
    $prob0 *= ($total_inconclusive_tweets / $total_sample);

    $proportionalConstant = 1.0 / ($prob1 + $prob0);

    $prob1 *= $proportionalConstant;
    $prob0 *= $proportionalConstant;

    $is_tweet_id_unreliable = $prob1 >= $prob0 ? 1:0;

    $sql_insert_tweets_naiveBayes->execute ($tweet_id, $is_tweet_id_unreliable, $prob1, $prob0);
}
#END Calculating all probabilities 2}}}

# END MAIN 1}}} 

