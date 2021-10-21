#!/bin/perl
# vim: set foldmethod=marker ts=4 expandtab sw=4:

#|--- Documentation {{{1
# 1}}}

#|--- Modules {{{1
use warnings;
use strict;
#1}}}

# I will consider that the first command line will be the dot file which
# will be applied the color scheme.

# The color scheme will consist of closer points getting warmer colors.
# Meanwhile, sparce points will have their edges coloured with colder 
# colors.

my $dotfilename;
my $fh, my $fh_write;

my $line;
my $colorflag;

my @nodes = ();
my $node;

my @edges = ();
my $edge;

my $point_Ax, my $point_Ay;
my $point_Bx, my $point_By;

my $dist, my $max_distances;

$dotfilename = @ARGV[0];
open ($fh, '<:encoding(UTF-8)', $dotfilename) 
    or die "Problems to read $dotfilename \n";

# Find the maximum value of all distances;
while (<$fh>) {

    $node = $1 if (m/(\d+)\s*\[height/);

    if (m/\s*pos="([\d.]+),([\d.]+)",/) {
            $point_Ax = $1; 
            $point_Ay = $2; 
    }
    push @nodes, {'node' => $node, 'pos_x' => $point_Ax, 'pos_y' => $point_Ay};

    if (m/(\d+) -- (\d+)/) {
        push @edges, {'from_node' => $1, 'to_node' => $2, 'distance' => 0.0};
    }
}
close $fh;

$max_distances = 0;
foreach $edge (@edges) {
    foreach (@nodes) {
        if ($edge->{'from_node'} == $_->{'node'}) {
            $point_Ax = $_->{'pos_x'};
            $point_Ay = $_->{'pos_y'};
        }
        if ($edge->{'to_node'} == $_->{'node'}) {
            $point_Bx = $_->{'pos_x'};
            $point_By = $_->{'pos_y'};
        }
    }

    $dist = sqrt( ($point_Ax - $point_Bx)**2 + ($point_Ay - $point_By)**2 );

    $max_distances = $max_distances < $dist ? $dist : $max_distances;

    $edge->{'distance'} = $dist;
}


# Now applies the color layers
open ($fh, '<:encoding(UTF-8)', $dotfilename) 
    or die "Problems to read $dotfilename \n";

open ($fh_write, '>', "coloured_plot.dot") 
    or die "Problems to write coloured_plot.dot \n";

while ($line = <$fh>) {

    if ($line =~ m/(\d+) -- (\d+)/) {
        foreach $edge (@edges) {
            last if ($edge->{'from_node'} == $1 && $edge->{'to_node'} == $2);
        }
        # color scheme with 9 colors
        if ($edge->{'distance'} <= 1/9.0 ) {
            $colorflag = 1;
        } elsif ($edge->{'distance'} <= 2/9.0 ) {
            $colorflag = 2;
        } elsif ($edge->{'distance'} <= 3/9.0 ) {
            $colorflag = 3;
        } elsif ($edge->{'distance'} <= 4/9.0 ) {
            $colorflag = 4;
        } elsif ($edge->{'distance'} <= 5/9.0 ) {
            $colorflag = 5;
        } elsif ($edge->{'distance'} <= 6/9.0 ) {
            $colorflag = 6;
        } elsif ($edge->{'distance'} <= 7/9.0 ) {
            $colorflag = 7;
        } elsif ($edge->{'distance'} <= 8/9.0 ) {
            $colorflag = 8;
        } else {
            $colorflag = 9;
        }

        $line =~ s/];$/, color=$colorflag];\n/; 
    }

    print $fh_write $line;
}

close $fh;
close $fh_write;


