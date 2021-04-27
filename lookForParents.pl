#!/usr/bin/perl
# vim: foldmethod=marker: set tw=90:

# TODO 
#|--- Documentation {{{1
# 
# GOAL: we will look for all tweet parents
# of each tweet stored into the twitter.db database.
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;
use DBI;
# 1}}}

#|--- Auxiliary Functions {{{1
# END OF AUXILIARY FUNCTIONS 1}}}

#|--- MAIN Program {{{1
#|--- Variables {{{2
my @tweet_ids;
my @tweet_ids_100;
my $parent_id;
my $tweet_form;
my $i, $j;
my $max_term_searches;

# database variables
my $dbfile   = 'twitter.db';
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = '';
my $password = '';
my $db_query;
# 2}}}

#|--- Loop untill we have found all parents of each tweet that we have {{{2
while(1){

	#|--- Lets find out the tweet_ids from twitter.db that we need to look up {{{3
	
	# Lets connect with the database.
	my $dbh = DBI->connect ($dsn, $user, $password, {
		PrintError		 => 0,
		RaiseError		 => 0,
		AutoCommit		 => 1,
		FetchHashKeyName => 'NAME_lc',
	});
	# We will store these tweet_ids into an array
	$db_query = "SELECT parent_tweet_id
		     FROM tweet
		     WHERE ( (parent_tweet_id IS NOT NULL) AND
		     	     (parent_tweet_id NOT IN (SELECT X.tweet_id 
			     			      FROM tweet as X)))";
	my $sqlCommand =  $dbh->prepare ($db_query);
	$sqlCommand->execute;
	push @tweet_ids, $parent_id  while ($parent_id = $sqlCommand->fetchrow_array);

	last if (!$tweet_ids);
	$dbh->disconnect;
	# 3}}}

	#|--- Given the tweet_ids above lets find out their parents {{{3
	@tweet_ids_100 = undef;
	for ($i = 0; $i <= $tweet_ids % 100; ++$i) {
		pop (@tweet_ids_100, (shift @tweet_ids)) for ($j = 0;$j < 100; ++$j);
	}
	
	# 3}}}
} 
# END OF THE LOOP 2}}}
# END OF MAIN 1}}}
