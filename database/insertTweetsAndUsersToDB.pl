#!/usr/bin/perl
# vim: foldmethod=marker:
#
#|--- Documentation {{{
# A tweet can be seen as as a set X which satisfies one of the following
# conditions (a) or (b):
#
#    -------         -------     |     ------- 
#    |  X  | <------ |  Y  |     |     |  X  | 
#    -------         -------     |     ------- 
#              (a)                       (b)
#
# In (a) the diagram means that the tweet X has a parent Y (also a tweet). 
# The meaning of Y being a parent of X is that X is an RT of Y or
# X is a quote of Y or, finally, X is an answer to the tweet Y.
#
# In case (b) the tweet X has no parent.
#
# With that in mind, we will understand a tweet X as the following set
#
#		 Tweet
#        ===========================================
#        || tweet X = {                           ||  
#        ||   type,                               ||   
#        ||                                       ||
#        ||   parent_tweet_id,                    ||
#        ||   parent_author_id,                   ||
#        ||                                       ||
#        ||   tweet_id,                           ||
#        ||   author_id,                          ||
#        ||                                       ||
#        ||   parent_tweet_created_at,            ||
#        ||   tweet_created_at,                   ||
#        ||                                       ||
#        ||   rt_count,                           ||
#        ||   reply_count,                        ||
#        ||   like_count,                         ||
#        ||   quote_count,                        ||
#        ||                                       ||
#        ||   language,                           ||
#        ||   text,                               ||
#        || }                                     ||
#        ===========================================
#        || Obs: 'type' has as values:            ||
#        || * retweeted;                          ||
#        || * replied_to                          ||
#        || * quoted_plus_replied_to              ||
#        || * simple_message                      ||
#        || * quoted_plus_simple_message 	  ||
#        ||                                       ||
#        || Obs: If a tweet has no parent then    ||
#        || parent_tweet_id and parent_author_id  ||
#        || will have the value undef.            ||
#        ===========================================
#
# (Obs: Note that the relation 'being a parent of' can be recursive.
#       By that I mean:  one tweet Y can be both a parent of a tweet X as 
#       well a son of a tweet Z.)
#
# As one would expect, Tweets are made by a user, which will be represented
# as 
#		 User
#        ===========================================
#        || User = {                              ||  
#        ||   id,                                 ||
#        ||   username,                           ||
#        ||   name,                               ||
#        ||                                       ||
#        ||   location,                           ||
#        ||                                       ||
#        ||   followers_count,                    ||
#        ||   following_count,                    ||
#        ||   tweet_count,                        ||
#        || }                                     ||
#        ===========================================
#
# (Obs: These representations will be used to store data at the hash
#       containers of perl. Not necessarily they will match the database 
#       architecture.)
# (Obs: Our database has its representation by an Entity-Relationship diagram.
# 		The diagram can be found here: 'er.png')
#
# }}}

use strict;
use warnings;

use DBI;

#print utf8 encoding at terminal!!!
binmode(STDOUT, ":utf8");

######################### AUXILIARY FUNCTIONS ##############################

#|--- Function: createTweetForm {{{
sub createTweetForm { 
# this function will receive as parameter an array and it will return
# a reference to a hash called Tweet.
# (Obs: This function must be used for the the JSON element called "data")
	my %Tweet;
	%Tweet = (
		type				 => undef,                                  
		quote_id			 => undef,
		parent_tweet_id 		 => undef,                    
		#parent_author_id 		 => undef,                   
		tweet_id 			 => undef,                           
		author_id 			 => undef,                          
		#parent_tweet_created_at  => '',            
		tweet_created_at 		 => undef,                   
		retweet_count			 => undef,                           
		reply_count 			 => undef,                        
		like_count 			 => undef,                         
		quote_count 			 => undef,                        
		language 			 => undef,                           
		text 				 => undef,
		place_id			 => undef
	);
	

	my $i    = 0;
	my @data = @_;
	my $temp1    = undef, my $temp2    = undef; # variables to handle type values
	my $temp1_id = undef, my $temp2_id = undef; # variables to handle type values

	while ($i < @_) {

		if ($data [$i] eq 'id') {
			$Tweet {'tweet_id'} = $data [++$i];
		}
		#elsif ($data [$i] eq 'referenced_tweets') {
		#	$i++;
		#	$Tweet {'type'} = $data [++$i];

		#	$i++;
		#	$Tweet {'parent_tweet_id'} = $data [++$i];
		#}
		elsif ($data [$i] eq 'type' && !defined($temp1)){
			$temp1 = $data [++$i];

			++$i;
			$temp1_id = $data [++$i];
		}
		elsif ($data [$i] eq 'type' && defined($temp1)){
			$temp2 = $data [++$i];

			++$i;
			$temp2_id = $data [++$i];
		}
		elsif ($data [$i] eq 'lang') {
			$Tweet {'language'} = $data [++$i];
		}
		elsif ($data [$i] eq 'author_id'){
			$Tweet {'author_id'} = $data [++$i];
		}
		elsif ($data [$i] eq 'created_at') {
			$Tweet {'tweet_created_at'} = $data [++$i];
		}
		elsif ($data [$i] eq 'public_metrics') {
			$i++;
			$Tweet {'retweet_count'} = $data [++$i];

			$i++;
			$Tweet {'reply_count'} = $data [++$i];

			$i++;
			$Tweet {'like_count'} = $data [++$i];

			$i++;
			$Tweet {'quote_count'} = $data [++$i];
		}
		elsif ($data [$i] eq 'text') {
			$Tweet {'text'} = $data [++$i];
		}
		elsif ($data [$i] eq 'place_id') {
			$Tweet {'place_id'} = $data [++$i];
		}

		$i++;
	}	
	
	if ( !defined($temp1) && !defined($temp2) ){
		$Tweet {'type'} = 'simple_message';
	}
	elsif ( defined($temp1) && !defined($temp2) ){
		if ($temp1 eq 'quoted') {
			$Tweet {'type'}            = 'quoted_plus_simple_message';
			$Tweet {'quote_id'}        = $temp1_id; 
		}
		elsif ($temp1 eq 'replied_to') {
			$Tweet {'type'}        	   = 'replied_to';
			$Tweet {'parent_tweet_id'} = $temp1_id;
		}
		else {
			$Tweet {'type'}            = 'retweeted';
			$Tweet {'parent_tweet_id'} = $temp1_id;
		}
	}
	else {
		$Tweet {'type'}     = 'quoted_plus_replied_to';
		$Tweet {'quote_id'} = $temp1_id if ($temp1 eq 'quoted');
		$Tweet {'quote_id'} = $temp1_id if ($temp2 eq 'quoted');

		$Tweet {'parent_tweet_id'} = $temp1_id if ($temp1 eq 'replied_to');
		$Tweet {'parent_tweet_id'} = $temp1_id if ($temp2 eq 'replied_to');
	}
	#$Tweet {'type'} = 'doesnt_have_parent' if (!defined ($Tweet {'type'}));
	
	##RT have their text not null now
	#$Tweet {'text'} = undef if ($Tweet {'type'} eq 'retweeted');
	return \%Tweet;
} # }}}

#|--- Function createUserForm {{{
sub createUserForm {
# this function will receive as parameter an array and it will return
# a reference to a hash called User.
	my %User;
	%User = (
		id 		 => undef,                          
		username         => undef,
		name             => undef,
		followers_count  => undef,
		following_count  => undef,
		tweet_count      => undef,
		location	 => undef,
		created_at	 => undef
	);
	

	my $i    = 0;
	my @data = @_;

	while ($i < @_) {

		if ($data [$i] eq 'id') {
			$User {'id'} = $data [++$i];
		}
		elsif ($data [$i] eq 'username') {
			$User {'username'} = $data [++$i];
		}
		elsif ($data [$i] eq 'name') {
			$User {'name'} = $data [++$i];
		}
		elsif ($data [$i] eq 'followers_count') {
			$User {'followers_count'} = $data [++$i];
		}
		elsif ($data [$i] eq 'following_count') {
			$User {'following_count'} = $data [++$i];
		}
		elsif ($data [$i] eq 'tweet_count') {
			$User {'tweet_count'} = $data [++$i];
		}
		elsif ($data [$i] eq 'location') {
			$User {'location'} = $data [++$i];
		}

		$i++;
	}	

	return \%User;
} # }}}

## TODO Incorporate a flag to the createTweetForm so
## the function below won't be necessary anymore.(CreateTweetForm2 is redundant)
#|--- Function createTweetForm2 {{{
sub createTweetForm2 {
# this function will receive as parameter an array and it will return
# a reference to a hash called Tweet.
# (Obs: This function must be used for the the JSON element called "tweets")
	my %Tweet;
	%Tweet = (
		type			 => undef,
		quote_id		 => undef,
		tweet_id 		 => undef,                           
		author_id 		 => undef,                          
		parent_tweet_id          => undef,
		tweet_created_at	 => undef,                   
		retweet_count		 => undef,                           
		reply_count 		 => undef,                        
		like_count 		 => undef,                         
		quote_count 		 => undef,                        
		language 		 => undef,                           
		text 			 => undef,
		place_id		 => undef
	);
	

	my $i    = 0;
	my @data = @_;
	my $temp1    = undef, my $temp2    = undef; # variables to handle type values
	my $temp1_id = undef, my $temp2_id = undef; # variables to handle type values

	while ($i < @_) {

		if ($data [$i] eq 'id') {
			$Tweet {'tweet_id'} = $data [++$i];
		}
		#elsif ($data [$i] eq 'referenced_tweets') {
		#	$i++;
		#	$Tweet {'type'} = $data [++$i];

		#	$i++;
		#	$Tweet {'parent_tweet_id'} = $data [++$i];
		#}
		elsif ($data [$i] eq 'type' && !defined($temp1)){
			$temp1 = $data [++$i];

			++$i;
			$temp1_id = $data [++$i];
		}
		elsif ($data [$i] eq 'type' && defined($temp1)){
			$temp2 = $data [++$i];

			++$i;
			$temp2_id = $data [++$i];
		}
		elsif ($data [$i] eq 'lang') {
			$Tweet {'language'} = $data [++$i];
		}
		elsif ($data [$i] eq 'author_id'){
			$Tweet {'author_id'} = $data [++$i];
		}
		elsif ($data [$i] eq 'created_at') {
			$Tweet {'tweet_created_at'} = $data [++$i];
		}
		elsif ($data [$i] eq 'public_metrics') {
			$i++;
			$Tweet {'retweet_count'} = $data [++$i];

			$i++;
			$Tweet {'reply_count'} = $data [++$i];

			$i++;
			$Tweet {'like_count'} = $data [++$i];

			$i++;
			$Tweet {'quote_count'} = $data [++$i];
		}
		elsif ($data [$i] eq 'text') {
			$Tweet {'text'} = $data [++$i];
		}
		elsif ($data [$i] eq 'place_id') {
			$Tweet {'place_id'} = $data [++$i];
		}

		$i++;
	}	
	
	if ( !defined($temp1) && !defined($temp2) ){
		$Tweet {'type'} = 'simple_message';
	}
	elsif ( defined($temp1) && !defined($temp2) ){
		if ($temp1 eq 'quoted') {
			$Tweet {'type'} 	   = 'quoted_plus_simple_message';
			$Tweet {'quote_id'}        = $temp1_id;
		}
		elsif ($temp1 eq 'replied_to') {
			$Tweet {'type'}        	   = 'replied_to';
			$Tweet {'parent_tweet_id'} = $temp1_id;
		}
		else {
			$Tweet {'type'} 	   = 'retweeted';
			$Tweet {'parent_tweet_id'} = $temp1_id;
		}
	}
	else {
		$Tweet {'type'}     = 'quoted_plus_replied_to';
		$Tweet {'quote_id'} = $temp1_id if ($temp1 eq 'quoted');
		$Tweet {'quote_id'} = $temp1_id if ($temp2 eq 'quoted');

		$Tweet {'parent_tweet_id'} = $temp1_id if ($temp1 eq 'replied_to');
		$Tweet {'parent_tweet_id'} = $temp1_id if ($temp2 eq 'replied_to');
	}
	#$Tweet {'type'} = 'doesnt_have_parent' if (!defined ($Tweet {'type'}));
	return \%Tweet;
} # }}}


### Printing function is not working ???
##sub printTweets {
##	my $temp = $_[0];
##	print "$_[0]\n";
##
##	print "$_ \t\t\t = $temp->{$_}\n" foreach (keys %{$temp});
##}


############################### MAIN #######################################
#|--- Important variables {{{
my @listOfTweets;
my @listOfUsers;

# iterators
my $i,
my $j,
my $tweetCounter,
my $userCounter;
# }}}

#|--- Storing all JSON entries into two hashes {{{
open my $fh , '<:utf8', $ARGV[0] || die "problem to open the file";


#### Selecting pairs (keyword:value) from the JSON file.
#### Regular expressions are used
my $text = <$fh>;

close $fh; # the file has only one line.

# Make every number not enclosed by quotes to be quoted.
$text =~ s/:(\d*?)([,}])/:\"$1\"$2/g;

# Making sure that the string "\\"" doesn't break my program.
# It happened when somebody wrote :-\\"
$text =~ s/\\\\"/\\\\ "/g;

# Making sure that double quotation inside text is done with single quotes
$text =~ s/\\"/'/g;

# Making sure that coordinate types won't ruin the program
$text =~ s/\"coordinates\":\{\"type\"/\"coordinates\":\{\"coordinates_type\"/g;

# Now we just need toselect all keywords from the JSON file. Every keyword
# is quoted. Thus we just need to do a quick search for double
# quotes

# But before, we need to wisely select {} such that all individuals and
# tweets can be selected separetedely.
$text =~ s/referenced_tweets\":\[([^}]*?)},\{(.*?)]/referenced_tweets\":\[$1,$2,/g;

$text =~ s/},\{/"}","\{"/g;


$text =~ s/"data":\[\{/"data":\["\{"/g;
$text =~ s/}],"includes"/"}"],"includes"/g;

$text =~ s/"users":\[\{/"users":\["\{"/g;
$text =~ s/}],"tweets"/"}"],"tweets"/g;

$text =~ s/"tweets":\[\{/"tweets":\["\{"/g;
$text =~ s/}]},"meta"/"}"]},"meta"/g;
$text =~ s/}]},"errors"/"}"]},"errors"/g;
$text =~ s/}],"places"/"}"],"places"/g;

#print $text;
#exit;

### Storing all info into hashs. Then we will export it to relational
### databases.
my @selected = $text =~ m/"(.*?)"/g;
#print @selected;
#exit;

$i = 0;
++$i until ($selected [$i] eq 'data');

++$i, $tweetCounter = 0;
until ($selected [$i] eq 'includes'|| $selected [$i] eq 'errors' || $selected [$i] eq 'places'){
	if ($selected [$i] eq '{') {
		$j = ++$i;
		++$j until ($selected [$j] eq '}');
		$listOfTweets [$tweetCounter] =
			createTweetForm @selected[$i .. ($j - 1)];
		$i = ++$j;
	}
	++$tweetCounter;
}

++$i until ($selected [$i] eq 'users');
#$i += 2, 
++$i, $userCounter = 0;
until ($selected [$i] eq 'tweets'|| $selected [$i] eq 'errors' || $selected [$i] eq 'places'){
	if ($selected [$i] eq '{') {
		$j = ++$i;
		++$j until ($selected[$j] eq '}');
		$listOfUsers [$userCounter] =
			createUserForm @selected [$i .. ($j - 1)];
		$i = ++$j;
	}
	++$userCounter;
}


++$i until ($selected [$i] eq 'tweets');
$i += 1;
until ($selected [$i] eq 'meta' || $selected [$i] eq 'errors' || $selected [$i] eq 'places'){
	if ($selected [$i] eq '{') {
		$j = ++$i;
		++$j until ($selected[$j] eq '}');
		$listOfTweets [$tweetCounter] =
			createTweetForm2 @selected [$i .. ($j - 1)];
		$i = ++$j;
	}
	++$tweetCounter;
}
# }}}

#|--- Debuging. STATUS: WORKING FINE {{{
#foreach (@listOfTweets) {
#	my %printTweet = %{$_};
#	print "$_ : $printTweet{$_}\n" foreach (keys %printTweet);
#	print "\n\n";
#}
#foreach (@listOfUsers) {
#	my %printUser = %{$_};
#	print "$_ : $printUser{$_}\n" foreach (keys %printUser);
#	print "\n\n";
#}
#foreach (@listOfTweets) {
#	my %printTweet = %{$_};
#	print "$_ : $printTweet{$_}\n" foreach (keys %printTweet);
#	print "\n\n";
#}
# }}}
     
#|--- INSERTING THE VALUES AT THE DATABASE {{{
#### Now we will export all data found at the JSON files
#### to our relational database
my $dbfile = 'twitter.db';

my $dsn = "dbi:SQLite:dbname=$dbfile";
my $user = '';
my $password ='';
my $dbh = DBI->connect ($dsn, $user, $password, {
	PrintError		 => 0,
	RaiseError		 => 0,
	AutoCommit		 => 1,
	sqlite_unicode		 => 1,
	FetchHashKeyName    	 => 'NAME_lc',
});

my %Tweet;
my $sqlCommand =  $dbh->prepare('INSERT INTO tweet VALUES (?,?,?,?,?,?,?,?,?,?,?,?)');
foreach (@listOfTweets){
	%Tweet = %{ $_ };

	$sqlCommand->execute($Tweet {'tweet_id'},
			     $Tweet {'author_id'},
			     $Tweet {'type'},
			     $Tweet {'retweet_count'},
			     $Tweet {'like_count'},
			     $Tweet {'reply_count'},
			     $Tweet {'quote_count'},
			     $Tweet {'language'},
			     $Tweet {'text'},
			     $Tweet {'tweet_created_at'},
			     $Tweet {'place_id'},
			     $Tweet {'parent_tweet_id'});

	if ( $sqlCommand->{err} ){
		print "\n";
		print "Problem with tweet: $Tweet{'tweet_id'}\n";
		print "Type:               $Tweet{'type'}\n";
		print "Author:             $Tweet{'author_id'}\n";

		print "\n";
		print "DBI ERROR! : $sqlCommand->{err} : $sqlCommand->{errstr} \n";
		print "\n";
		print "\n";
	}
}

my %User;
$sqlCommand =  $dbh->prepare('INSERT INTO twitter_user VALUES (?,?,?,?,?,?,?)');
foreach (@listOfUsers) {
	%User = %{ $_ };

	$sqlCommand->execute($User {'id'},
			     $User {'name'},
			     $User {'username'},
			     $User {'location'},
			     $User {'followers_count'},
			     $User {'following_count'},
			     $User {'tweet_count'});

	if ( $sqlCommand->{err} ){
		print "\n";
		print "Problem with user: $User{'id'}\n";
		print "\n";
		print "DBI ERROR! : $sqlCommand->{err} : $sqlCommand->{errstr} \n";
	}
}
$dbh->disconnect;
# }}}
