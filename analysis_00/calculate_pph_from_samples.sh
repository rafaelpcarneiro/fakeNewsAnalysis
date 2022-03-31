echo -n "Running these calculations from which cpu: 0 or 1? "
read answer

cd filtration_samples/
if [ $answer -eq 0 ]; then
    for i in {0..49};
    do
        sh sampling_from_twitter_script.sh
        ./pph_prog
        file="sample_""$i"
        mv data/ -t ../$file
    done
else
    for i in {50..99};
    do
        sh sampling_from_twitter_script.sh
        ./pph_prog
        file="sample_""$i"
        mv data/ -t ../$file
    done
fi
