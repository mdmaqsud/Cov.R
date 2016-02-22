find . -type f -name '*.convert.distribution' -print | while read filename; do
    echo "$filename"
    cat "$filename"
done > concatenated.convert.distribution.txt
