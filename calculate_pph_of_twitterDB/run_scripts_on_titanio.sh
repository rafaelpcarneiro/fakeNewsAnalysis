#!/bin/bash

# On "Titanio" cluster we have the following specs:
# 
#  * 40 nodes of type 2
#  * Each node of type 2 has
#      + 2 sockets;
#      + each socket has 16 cpus;
#      + each cpu has 16 threads;
#
#
# This means that 1 socket == 16*16 cores
#
# NOte: Calculating persistence diagrams of dimension 0 and 1 will use 2 threads
#
# Note: I will use all resources available at one socket. This means
#       that I will allocate 128 threads or, equivalently, 16 cores.

#local instances=2
#total_of_processes=128   #16 * 8
total_of_processes=2   #16 * 8

i=0
while [ $i -lt $total_of_processes ]; do
    ./calculate_pph_from_samples.sh $i > /dev/null &
    i=$((i+1))
done
