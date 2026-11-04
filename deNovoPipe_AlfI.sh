#!/bin/bash

#usage: qsub <options> deNovoPipe_AlfI.sh path 
#eg: qsub -l h_vmem=50G deNovoPipe_AlfI.sh path 
#change xxx with the path were scripts are located

path="$1"
cd $path

a=no_adapter_seq
b=fasta
c=elab
d=Trimmed
site=".{11}GCA.{6}TGC.{11}"	#recognize site "ALfI"; 34bp
len=34

test -d $a || mkdir -p $a
test -d $b || mkdir -p $b
test -d $c || mkdir -p $c
test -d $d || mkdir -p $d

for file in *.fastq.gz
    do
    	#remove adapters
	python2.7 /xxx/cutadapt-1.5/bin/cutadapt -a AGATCGGAAGAGC  --discard-untrimmed $file > no_adapter_seq/cutadap_$file
    done

gzip -f ./no_adapter_seq/*gz

for file in ./no_adapter_seq/*.gz;
    do
	new_filename=$(echo $file |sed -r 's/^\.\/.*\/(.*.fast).*/\1a/')
	#fastq to fasta. (from AlfI trimmed script)
        zcat $file | perl -e '$i=0;while(<>){if(/^\@/&&$i==0){s/^\@/\>/;print;}elsif($i==1){print;$i=-3}$i++;}' | sed 's/\s.*//'> ./fasta/$new_filename
    done

for file in ./fasta/*.fasta;
    do
	new_filename=$(echo $file |sed -r 's/^\.\/.*\/(.*.fast).*/\1a/')
        #Truncating all reads at nucleotide 36.
        cat $file | perl /xxx/TruncateFastq.pl $file 1 36 ./elab/$new_filename
    done

for file in ./elab/*.fasta;
    do
	new_filename=$(echo $file |sed -r 's/^\.\/.*\/(.*.fast).*/\1a/')
	#recognizes the AlfI site and cuts the sequences
        cat $file | sed 's/\s.*//'| /xxx/2b_Extract_mod.pl $file $site ./elab/$new_filename.trimm
    done

for file in ./elab/*.trimm;
    do
	new_filename=$(echo $file |sed -r 's/^\.\/.*\/(.*trimm)/\1/')
	#discard sequences with a length different than a threshold
	python /xxx/extractFasta_lengthThres.py $file $len ./Trimmed/$new_filename
    done

rm -r ./elab/ #comment in case you want to keep this sequences
rm -r ./fasta/ #comment in case you want to keep this sequences
rm -r ./no_adapter_seq/ #comment in case you want to keep this sequences

exit

#cd /xxx/Trimmed
#rename -v 's/cutadap_//' *.trimm
#rename -v 's/.trimm//' *.trimm
