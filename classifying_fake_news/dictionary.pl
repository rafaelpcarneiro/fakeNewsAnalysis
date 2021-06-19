#!/usr/bin/perl
# vim: set ts=4 expandtab sw=4 foldmethod=marker:


#|--- Documentation {{{1
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;
use DBI;

use POSIX;

use utf8;
use open ':encoding(utf8)';
binmode(STDOUT, ":utf8");
binmode(STDIN, ":encoding(utf8)");
#1}}}

#|--- Functions {{{1

# |--- createDict {{{2
sub createDict {
	my ($text) = @_;
	my %dict;
    my @words;

	# |--- Filtering words {{{3
	
    sleep 5;
	# Uppercase to Lowercase
	$text = lc $text;
    
    # Removing links 
    $text =~ s/https:\/\/[^\s]*/  /g;
    
	# Removing unicode symbols and \n and \t
	$text =~ s/(\\u.{4}|\\n|\\t)/  /g;

    # Removing everything that is [^\wáéíóúãẽĩõũâêîôû]
    $text =~ s/[^\wáéíóúãẽĩõũâêîôûç]/  /g;

    # Removing . , - / \ @ # ! ? ...
    #$text =~ s/[ \. , ! \? : \( ) \[ \] \{ \} 
	#             \- \# \@ \+ \- \* < > \\ \| \' \" ]+/ /g;

	# Removing articles 
    #$text =~ s/\s[aeiou]+ / /g;
	#$text =~ s/^[aeiou]+ / /g;
	#$text =~ s/\s[aeiou]+$/ /g;

	# Removing only numbers 
    #$text =~ s/\s[\d]+ / /g;
	#$text =~ s/^[\d]+ / /g;
	#$text =~ s/\s[\d]+$/ /g;


    # Removing words that do not bring context to the tweet
    #$text =~ s/\s(de|da|do|dos|um|uns|uma|ele|ela|você|vc)\s/ /g;
    #$text =~ s/\s(só|so|esse|na|sem|que|ser|é|para)\s/ /g;
    #$text =~ s/\s(das|dos|deles|eles|elas|vocês|vcs|os|as)\s/ /g;
    #$text =~ s/\s(em|até|to|por|tô)\s/ /g;
    #$text =~ s/\s(nem|já|se|sou|tá)\s/ /g;


	# Spliting the whole text into words
	# |--- END Filtering words 3}}}

	@words = split (/[ \s \. , ! \? : \( ) \[ \] \{ \} 
	        	       \- \# \@ \+ \- \* < > \\ \| \' \" ]+/, $text);

	foreach (@words) {
        next            unless $_ =~ /^\w+$/;
		$dict{$_}  += 1 if (exists $dict{$_});
		$dict{$_}   = 1 unless (exists $dict{$_});
	}

	return \%dict;
}
# END createDict 2}}}
 
#|--- printDict {{{2
sub printDict {
    my $dict, my $file_index, my $tweet_id;
    ($dict, $tweet_id, $file_index) = @_;

    open (my $fh, '>', "$file_index" . ".txt")
        or die "Problems to write the file!\n";

    foreach (keys %$dict) {
        #binmode( $fh, ":utf-8");
        print $fh "$tweet_id \t $_ \t $dict->{$_}\n"
    }
    close $fh;
}
# END printDict 2}}}
 
# 1}}}

#|--- MAIN {{{1

#|--- Variables {{{2

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
my $sql_query02;

my $text;
my $tweet_id;

my $counter;
my $i, my $j;

my $pid, my $kid;

my $dictionary;

my @tweetID_text;
# END VARIABLES 2}}}

#|--- Declaring SQL commands to be executed {{{2
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

# 2}}}

#|--- Executing SQL commands {{{2
$sql_query01->execute ();
$counter = 0;
while (($tweet_id, $text) = $sql_query01->fetchrow_array) {
    push @tweetID_text, {tweet_id => $tweet_id, text => $text};
    
    print "Reading  ==> tweet_id = $tweet_id \n";
    ++$counter;
}
#END Executing SQL commands 2}}}
#print "Counter = $counter\n";
# Counter = 81433

#|--- Creating the dictionary {{{2
print "\n\nBuilding the dictionary\n\n";
my $tmp = @tweetID_text;
print "Amount of tweets to process $tmp \n\n";
sleep 5;

my $TWEETS_PER_FORK = 100;
my $MAX_FORKS = floor ($counter / $TWEETS_PER_FORK);

for ($i = 1; $i <= $MAX_FORKS; ++$i) {

    $pid = fork;
    die "Failed to fork -- iteration $i\n\n" unless (defined $pid);

    #$dictionary = $tweetID_text[0];
    print "Fork -> $i\n";
    unless ($pid) {
        for ($j = $TWEETS_PER_FORK * ($i-1); $j < $TWEETS_PER_FORK * $i; ++$j) {
            $dictionary = $tweetID_text [$j];

            $text       = $dictionary->{'text'};
            $tweet_id   = $dictionary->{'tweet_id'};

            $dictionary = createDict ($text);
        
            printDict ($dictionary, $tweet_id, $j);
        }
        exit;
    }
}
for ($j = $TWEETS_PER_FORK * ($MAX_FORKS); $j < $counter; ++$j) {
    $dictionary = $tweetID_text [$j];

    $text       = $dictionary->{'text'};
    $tweet_id   = $dictionary->{'tweet_id'};

    $dictionary = createDict ($text);

    printDict ($dictionary, $tweet_id, $j);
}

do {
    $kid = waitpid -1, 0;
} while ($kid > 0);
#END Creating the dictionary 2}}}

#$dbh->disconnect;


# END MAIN 1}}} 
