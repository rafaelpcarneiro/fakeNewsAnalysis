#!/usr/bin/perl
# vim: foldmethod=marker:

#|--- Documentation {{{1
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;
use DBI;
#1}}}

#|--- Functions {{{1
sub check_error_sql_call {
	my ($sql_call) = @_;
	die "\nDBI ERROR! : $sql_call->{err} : $sql_call->{errstr} \n" if ($sql_call->{err});
}
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
	FetchHashKeyName	 => 'NAME_lc',
});

my $sql_amountOfSons_root_tt;

my $sql_amountOfSonsGenX;
my $sql_sonsOfGenerationX;

my $sql_insert_0;
my $sql_insert_1;
my $sql_update_1;

my $sql_maxSonsOfGenerationX;
my $maxSonsOfGenerationX;

my $sql_output_0;
my @sql_output;

my $generation;

# END VARIABLES 2}}}

#|--- Checking for the nodes of the graph by each generation {{{2

#|--- Declaring SQL commands to be executed at each generation {{{3
$sql_amountOfSons_root_tt =  $dbh->prepare ("SELECT parent_tweet_id, COUNT(tweet_id) 
				             FROM tweet
				             WHERE parent_tweet_id IN (SELECT * 
								       FROM root_tt)
					     GROUP BY parent_tweet_id"
			     );

$sql_amountOfSonsGenX     =  $dbh->prepare ("SELECT parent_tweet_id, COUNT(tweet_id) 
				             FROM tweet
				             WHERE parent_tweet_id IN (SELECT nodes.tweet_id 
								       FROM  nodes
								       WHERE nodes.generation_of_tweet_id = ?)
					     GROUP BY parent_tweet_id"
			     );

$sql_sonsOfGenerationX    =  $dbh->prepare ("SELECT tweet_id
				             FROM tweet
				             WHERE parent_tweet_id IN (SELECT nodes.tweet_id 
								       FROM  nodes
								       WHERE nodes.generation_of_tweet_id = ?)"
			     );

$sql_maxSonsOfGenerationX = $dbh->prepare ("SELECT MAX(amount_of_sons)
					    FROM nodes
					    WHERE generation_of_tweet_id = ?"
			    );

$sql_insert_0             = $dbh->prepare ("INSERT INTO nodes(tweet_id, generation_of_tweet_id) VALUES (?,?)");
$sql_insert_1             = $dbh->prepare ("INSERT INTO nodes VALUES (?,?,?)");
$sql_update_1             = $dbh->prepare ("UPDATE nodes
					    SET amount_of_sons = ?
					    WHERE tweet_id  = ?");
# 3}}}

#|--- Executing SQL commands at each generation {{{3
$generation = 0;
do {
	print "Generation = $generation\n";

	if ($generation == 0) {
		$sql_amountOfSons_root_tt->execute ();
		while (@sql_output = $sql_amountOfSons_root_tt->fetchrow_array) {
			$sql_insert_1->execute ($sql_output[0], $generation, $sql_output[1]);
		}

		# Now store the next generation of nodes for the next iteration of the loop
		$sql_sonsOfGenerationX->execute ($generation);

		while (($sql_output_0) = $sql_sonsOfGenerationX->fetchrow_array) {
			$sql_insert_0->execute ($sql_output_0, $generation+1);
		}
	}
	else {
		$sql_amountOfSonsGenX->execute ($generation);

		while (@sql_output = $sql_amountOfSonsGenX->fetchrow_array) {
			$sql_update_1->execute ($sql_output[1], $sql_output[0]);
		}

		# Now store the next generation of nodes for the next iteration of the loop
		$sql_sonsOfGenerationX->execute ($generation);

		while (($sql_output_0) = $sql_sonsOfGenerationX->fetchrow_array) {
			$sql_insert_0->execute ($sql_output_0, $generation+1); 
		}
	}

	# Now check if there is any son on next generation. In case there is not,
	# cease the loop.
	$sql_maxSonsOfGenerationX->execute ($generation);

	($maxSonsOfGenerationX) = $sql_maxSonsOfGenerationX->fetchrow_array;

	++$generation;
} while ($maxSonsOfGenerationX > 0);
# 3}}}

# 2}}}

# END MAIN 1}}} 

