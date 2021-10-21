#!/usr/bin/perl
# vim: foldmethod=marker:

#|--- Modules {{{1
use warnings;
use strict;
use DBI;
#1}}}

#|--- MAIN {{{1

#|--- Variables {{{2

# Relational Database
my $dbfile = 'twitter.db';

my $dsn = "dbi:SQLite:dbname=$dbfile";
my $user = '';
my $password ='';
my $dbh = DBI->connect ($dsn, $user, $password, {
    PrintError       => 0,
    RaiseError       => 1,
    AutoCommit       => 1,
    sqlite_unicode   => 1,
    FetchHashKeyName => 'NAME_lc',
});

my $sql_select;

# Edges
my @List_of_edges;
my @edges;
my $node1, my $node2;
my $from_nodeA, my $to_nodeB;
my $i, my $file_index;
my $filename, my $fh;
my $string;

# END VARIABLES 2}}}

#|--- Checking for the connected components {{{2

#|--- Declaring SQL command to select all edges {{{3
$sql_select = $dbh->prepare (
                "SELECT DISTINCT
                    from_author_tweet_id, to_author_tweet_id
                 FROM 
                    paths_xy
                 WHERE
                    path_distance = 1
                    AND 
                    from_author_tweet_id != -1"
);

# 3}}}

#|--- Looping through all edges and connecting them {{{3
$sql_select->execute ();

while (($from_nodeA, $to_nodeB) = $sql_select->fetchrow_array) {
    push @List_of_edges, { from_node => $from_nodeA, to_node => $to_nodeB };
}

$file_index = 0;
while (@List_of_edges > 0) {
    @edges = ();

    push @edges, shift @List_of_edges;
    for ($i = 0; $i < @List_of_edges; ++$i) {
        $node1 = $List_of_edges[$i];

        foreach $node2 (@edges) {
            if ( $node2->{'to_node'} == $node1->{'from_node'} || 
                 $node1->{'to_node'} == $node2->{'from_node'} ) 
            {
                push @edges, $node1;
                splice @List_of_edges, $i, 1;
                --$i;
                last;
            }
        }
    }
    $filename = "connected_component" . $file_index . ".txt";
    open ($fh, '>', $filename)
        or die "Problems to export data to $filename\n";

    foreach $node2 (@edges) {
        $string = $node2->{'from_node'} . " -- " . $node2->{'to_node'};
        print $fh $string;
    }
    close $fh;
}

# 3}}}

# 2}}}

# END MAIN 1}}} 

