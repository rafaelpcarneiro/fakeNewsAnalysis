while IFS= read -r line; do
    branchSize=`echo $line |wc -w`
    if [ $branchSize -ge $1 ]; then
        echo $line
    fi
done < allBranches.txt
