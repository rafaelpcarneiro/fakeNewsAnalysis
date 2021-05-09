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

my $sql_query01;
my $sql_query02;
my $sql_query03;

my $sql_insert;

my $generation;
my $iterator;
my $x;
my $y;
my $z;
my $z_parent;

# END VARIABLES 2}}}

#regular path [x,y,z] means x -> y -> z 
#|--- Generating regular paths [x,y] of dimension 1  {{{2

#|--- Declaring SQL commands to be executed at each generation {{{3
$sql_query01 =  $dbh->prepare ("SELECT tweet_id, parent_tweet_id
				FROM   tweet
				WHERE  tweet_id IN (SELECT X.tweet_id
						    FROM   nodes AS X
						    WHERE  X.generation_of_tweet_id = ?)");

$sql_query02 = $dbh->prepare ("SELECT MAX(amount_of_sons)
			       FROM   nodes
			       WHERE  generation_of_tweet_id = ?");

$sql_query03 = $dbh->prepare ("SELECT x, y
			       FROM   paths_xy
			       WHERE  y = ?");

$sql_insert  = $dbh->prepare ("INSERT INTO paths_xy VALUES (?,?,?,?,?,?)");
# 3}}}

#|--- Executing SQL commands at each generation {{{3
$generation = 2;
do {
	$sql_query01->execute ($generation);
	while (($z, $z_parent) = $sql_query01->fetchrow_array) {
		$sql_query03->execute ($z_parent);
		($x, $y) = $sql_query03->fetchrow_array;

		$sql_insert->execute ($x, $y, $z, $generation - 2, $generation-1, $generation);
		print $x, $y, $z, $generation - 2, $generation - 1, $generation, "\n";
	}

	$sql_query02->execute ($generation);
	($iterator) = $sql_query02->fetchrow_array;
	++$generation;

} while ($iterator);
# 3}}}

$dbh->disconnect;

# 2}}}

# END MAIN 1}}} 

