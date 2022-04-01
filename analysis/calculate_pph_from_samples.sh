# cpu_core = 0, 1, 2, 3
cpu_core=$1
loopStart=$((cpu_core * 300))
loopEnd=$((loopStart + 300))

cd ../pph_in_C
make
make clean
mv pph_prog -t ../analysis/filtration_samples$cpu_core
cd ../analysis/

for graph in mariliaMendonca football f1 mitoVisitaPutin onu politcsAR
do
    cp $graph/twitter.db -t filtration_samples$cpu_core/ 

    cd $graph/
    dateStart=`head -n 1 dates.txt`
    dateEnd=`tail -n 1 dates.txt`
    sampleSize=20

    cd ../filtration_samples$cpu_core/

    #for i in {0..299};
    i=$loopStart
    while [ $i -lt $loopEnd ]
    do
        sh sampling_from_twitter_script.sh $dateStart $dateEnd $sampleSize
        ./pph_prog
        file="sample_""$i"
        mv data/ ../$graph/$file

        i=$((i+1))
    done
    cd ../
done

