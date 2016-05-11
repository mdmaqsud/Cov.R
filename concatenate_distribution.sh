#####concatenate alu variants
find . -type f -name '*overlap.alu.distribution' -print | while read filename; do
    echo "$filename"
    cat "$filename"
done > concatenated.alu.distribution
#####concatenate non alu variants
find . -type f -name '*overlap.nonalu.distribution' -print | while read filename; do
    echo "$filename"
    cat "$filename"
done > concatenated.nonalu.distribution
#####concatenate non alu removed homopolymeric sites variants
find . -type f -name '*overlap.nonalu.rmhom.distribution' -print | while read filename; do
    echo "$filename"
    cat "$filename"
done > concatenated.overlap.nonalu.rmhom.distribution


#####concatenate non alu removed homopolymeric homozygous sites variants
find . -type f -name '*overlap.nonalu.rmhom.rmhomozygous.distribution' -print | while read filename; do
    echo "$filename"
    cat "$filename"
done > concatenated.overlap.nonalu.rmhom.rmhomozygous.distribution 
