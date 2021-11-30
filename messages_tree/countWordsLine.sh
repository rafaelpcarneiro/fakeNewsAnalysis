while IFS= read -r line; do
    echo $line |wc -w
done < branches.txt
