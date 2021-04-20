#!/usr/bin/perl
# vim: foldmethod=marker: set tw=80:

#|--- Documentation {{{1
# 
# GOAL: we will look for all tweet parents
# of each tweet stored into the twitter.db database.
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;
# 1}}}

#|--- Auxiliary Functions {{{1
# END OF AUXILIARY FUNCTIONS 1}}}

#|--- MAIN Program {{{1
#|--- Variables {{{2
my @tweet_ids;

my $i;
# 2}}}

#|--- Loop untill we have found all parents of each tweet that we have {{{2
while(1){

#|--- Lets find out the tweet_ids from twitter.db that we need to look up {{{3

# We will store these tweet_ids into an array
# 3}}}
	last if (!defined(@check));

#|--- Given the tweet_ids above lets find out their parents {{{3

# 3}}}
} 
# END OF THE LOOP 2}}}
# END OF MAIN 1}}}

