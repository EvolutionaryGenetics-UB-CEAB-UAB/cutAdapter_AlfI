#Return: A fasta file with the longest transcript for each gene ID
#input: ncbi transcripts fasta

from Bio import SeqIO
import sys

file1 = open(sys.argv[1]) #fasta
threshold = sys.argv[2]
file2 = sys.argv[3]
file2 = open(file2, "w")

#myList= [x.rstrip() for x in file2]
i=0; j=0
for seq in SeqIO.parse(file1, "fasta"):
    if len(seq.seq) == int(threshold):
        file2.write(">%s\n%s\n" % (seq.description, seq.seq))
        i+=1
    else:
        #print("WARNING: %s length was not %s" %(seq.description, threshold))
        j+=1
        print("%s\t%s" % (seq.description,len(seq.seq)))
        
print("number of sequences with length %s: %s" % (threshold,i))
print("number of sequences with length NOT %s: %s" % (threshold,j))