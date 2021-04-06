#!/usr/bin/perl
#
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
#        ||										  ||
#        || Obs: 'type' has as values RT, T, Q, A.||
#        || * RT stands for retweet;              ||
#        || * T stands for a tweet with no parent ||
#        || * Q means a quote (RT + message)      ||
#        || * A means an answer to someone        ||
#        ||										  ||
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

use strict;
use warnings;


#print utf8 encoding at terminal!!!
binmode(STDOUT, ":utf8");

######################### AUXILIARY FUNCTIONS ##############################
sub createTweetForm {
# this function will receive as parameter an array and it will return
# a reference to the hash Tweet.
	my %Tweet;
	%Tweet = (
		type					 => '',                                  
		parent_tweet_id 		 => '',                    
		parent_author_id 		 => '',                   
		tweet_id 				 => '',                           
		author_id 				 => '',                          
		parent_tweet_created_at  => '',            
		tweet_created_at 		 => '',                   
		rt_count 				 => '',                           
		reply_count 			 => '',                        
		like_count 				 => '',                         
		quote_count 			 => '',                        
		language 				 => '',                           
		text 					 => '',                               
	);
	

	my $i    = 0;
	my @data = @_;

	while ($i < @_) {

		if ($_ eq 'id') {
			$Tweet{'id'} = $data[ $i ];
		}
		elsif ($_ eq 'referenced_tweets') {
			$i++;
			$Tweet{'type'} = $data[ $i ];

			$i++;
			$Tweet{'parent_tweet_id'} = $data[ $i ];
		}
		elsif ($_ eq 'lang') {
			$Tweet{'lang'} = $data[ $i ];
		}
		elsif ($_ eq 'author_id'){
			$Tweet{'author_id'} = $data[ $i ];
		}
		elsif ($_ eq 'created_at') {
			$Tweet{'tweet_created_at'} = $data[ $i ];
		}
		elsif ($_ eq 'public_metrics') {
			$i++;
			$Tweet{'rt'} = $data[ $i ];

			$i++;
			$Tweet{'reply_count'} = $data[ $i ];

			$i++;
			$Tweet{'like_count'} = $data[ $i ];

			$i++;
			$Tweet{'quote_count'} = $data[ $i ];
		}
		elsif ($_ eq 'text') {
			$Tweet{'text'} = $data[ $i ];
		}

		$i++;
	}	

	return \%Tweet;
}


############################### MAIN #######################################
# important variables
my @listOfTweets;
my @listOfUsers;

# iterators
#my $i, $j;

open my $fh , '<:utf8', $ARGV[0] || die "problem to open the file";

my $text = <$fh>;
close $fh; # the file has only one line.


# Make every number not enclosed by quotes to be quoted.
$text =~ s/:(\d.*?)([,}])/:\"$1\"$2/g;

# Now we select all keywords from the JSON file. Every keyword
# is quoted. Thus we just need to do a quick search for double
# quotes

# Now we need to wisely select {} such that all individuals and
# tweets can be splited.
$text =~ s/},\{/"}","\{"/g;

$text =~ s/"data":\[\{/"data":\["\{"/g;
$text =~ s/}],"includes"/"}"],"includes"/g;

$text =~ s/"users":\[\{/"users":\["\{"/g;
$text =~ s/}],"tweets"/"}"],"tweets"/g;

$text =~ s/"tweets":\[\{/"tweets":\["\{"/g;
$text =~ s/}]},"meta"/"}"]},"meta"/g;
#$i = 0;


my @selected = $text =~ m/"(.*?)"/g;
print @selected;

#while ( $i < @selected ){
#
#	if ( $selected[i] eq 'data' ) {
#		$j = 
#	}
#}
