#!/bin/bash
# cpu_core values = 0, 1, 2, 3
# they will split the calculations through the cpu cores
cpu_core=0


sampleSize='20'
amountOfSamples=100


if [ $# -eq 1 ] 
then
    cpu_core=$1
    cp -r filtration_samples/ filtration_samples$cpu_core
elif [ $# -eq 0 ] 
then 
    cpu_core=0
else
    echo "Only zero or one argument"
    exit 1
fi

loopStart=$((cpu_core * amountOfSamples))                                                       
loopEnd=$((loopStart + amountOfSamples))

# Compile pph.c
cd ../pph_in_C                                                                      
make                                                                                
make clean    
if [ $# -eq 1 ]
then
    mv pph_prog -t ../calculate_pph_of_twitterDB/filtration_samples$cpu_core
else
    mv pph_prog -t ../calculate_pph_of_twitterDB/filtration_samples
fi

cd ../calculate_pph_of_twitterDB

### Lets calculate the persitent homology!
###
### For the sake of simplicity keep all twitter.db files
### inside a folder named graph_LABEL.
###
### For example, consider that we have a database whose tweets are related
### with politics. Then we can have something like
###     graph_politcs/
###          |
###          ----- twitter.db
###          |
###          ----- dates.txt
###
### Here twitter.db is the database and dates.txt is a text file
### whose the first line we have the first day we collected the data and
### the second line is related with tweets that might have passed midnight
### at UTC 0 but are still the same day on the respectively time zone
###
### For example, in Brazil tweets collected 
###      from 2022-01-01T12:00:00Z (UTC -3)
###      to   2022-01-01T23:59:59Z (UTC -3)
### are represented as 
###      from 2022-01-01T15:00:00Z (UTC)
###      to   2022-01-01T02:59:59Z (UTC)
###
### so dates.txt must contain only two lines
###   2022-01-01
###   2022-01-02


for graph in  graph_*
do
    cd $graph/
    dateStart=`head -n 1 dates.txt`
    dateEnd=`tail -n 1 dates.txt`
    cd ../

    if [ $# -eq 1 ]
    then
        cp $graph/twitter.db -t filtration_samples$cpu_core/
        cd filtration_samples$cpu_core/
    else
        cp $graph/twitter.db -t filtration_samples
        cd filtration_samples
    fi


    #for i in {0..299};
    i=$loopStart
    while [ $i -lt $loopEnd ]
    do
        bash sampling_from_twitter_script.sh $dateStart $dateEnd $sampleSize
        ./pph_prog
        file="sample_""$i"
        mv data/ ../$graph/$file

        i=$((i+1))
    done
    cd ../
done
