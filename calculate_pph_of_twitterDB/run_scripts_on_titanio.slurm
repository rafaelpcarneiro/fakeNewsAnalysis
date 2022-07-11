#!/bin/bash
#SBATCH --job-name=sbatch_training                  # Job name
#SBATCH --mail-type=END                             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=rafael.carneiro@ufabc.edu.br    # Where to send mail	
#SBATCH --nodes=1                                   # Run all processes on a single node	
#SBATCH --ntasks=1                                  # Run a single task		
#SBATCH --cpus-per-task=100                         # Number of CPU cores per task
#SBATCH --mem=12gb                                  # Job memory request
#SBATCH --time=02:00:00                             # Time limit hrs:min:sec
#SBATCH --output=sbatch_training_%j.log             # Standard output and error log

#local instances=2
#total_of_processes=128   #16 * 8
total_of_processes=50   #16 * 8

# On Titanio cluster we have the following specs:
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

### LOG info
pwd; echo ""; hostname; echo ""; date; echo ""



i=0
while [ $i -lt $total_of_processes ]; do
    ./calculate_pph_from_samples.sh $i > /dev/null &
    pid[$i]=$!
    i=$((i+1))
done

topLog=10
while [ $topLog -eq 130 ]; do
    sleep 10m
    top -u rafael.carneiro -b -n 1 > $topLog".log"
    topLog=$((topLog+10))
done

for pid in ${pids[*]}; do
    wait $pid
done

echo ""
date
