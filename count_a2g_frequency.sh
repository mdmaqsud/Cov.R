in=$1

id=$2

awk '$4=="A" && $5=="G" { sum += $6; n++ } END { if (n > 0) print sum / n; }' $in > ${id}.a2g.frequency
