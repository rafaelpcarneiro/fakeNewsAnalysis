#!/usr/bin/perl
# vim: set ts=4 expandtab sw=4 foldmethod=marker:


#|--- Documentation {{{1
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;
use DBI;

use utf8;
use open ':encoding(utf8)';
binmode(STDOUT, ":utf8");
binmode(STDIN, ":encoding(utf8)");

use POSIX;
#1}}}

#|--- MAIN {{{1


# Relational Database
my $dbfile   = 'twitter.db';
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = '';
my $password = '';
my $dbh      = DBI->connect ($dsn, $user, $password, {
	PrintError		 => 0,
	RaiseError		 => 1,
	AutoCommit		 => 1,
    sqlite_unicode   => 1,
	FetchHashKeyName => 'NAME_lc',
});

my $sql_query01;

my $text;
my $tweet_id;

my $counter;

my @tweetID_text;

$sql_query01 =  $dbh->prepare ("SELECT 
                                    tweet_id, text
			                    FROM
                                    tweet
                                WHERE
                                    tweet_id IN (SELECT
                                                    x.tweet_id 
                                                 FROM
                                                    nodes AS x
                                                 WHERE
                                                    tweet_id = x.tweet_id)
                                     AND
                                     created_at IS NOT NULL
                                     AND
                                     text IS NOT NULL");


$sql_query01->execute ();
$counter = 0;
while (($tweet_id, $text) = $sql_query01->fetchrow_array) {
    push @tweetID_text, {tweet_id => $tweet_id, text => $text};
    
    #print "Reading  ==> tweet_id = $tweet_id \n";
    ++$counter;
}

# Sampling
my $sample;
my $fh;
my $dict;
my $counter2;
my @rand_numbers;
my $j;

open $fh, '>', 'naiveBayes.sample'
    or die "Problems to create the sample file";

srand (666);
$sample   = floor (rand ($counter));
push        @rand_numbers, $sample;
$counter2 = @rand_numbers;

while ($counter2 < 4072) {
    print "Sample $counter2\n";

    $dict = $tweetID_text [$sample];
    print $fh "TWEET_ID == $dict->{'tweet_id'}\n"; 
    print $fh "TEXT\n$dict->{'text'}\n\n"; 

    $sample = floor (rand ($counter));
    $j      = 0;
    while (j < $counter2) {
        if ($rand_numbers [$j] == $sample) {
            $j = 0;
            $sample = floor (rand ($counter));
        }
        else {
            ++$j;
        }
    }
    push        @rand_numbers, $sample;
    ++$counter2;
}
close $fh;




# $dbh->disconnect;


# END MAIN 1}}} 
