## BALDR

BALDR is a pipeline for reconstructing human or rhesus macaque immunoglobulin(Ig)/B cell receptor(BCR) sequences from single cell RNA-Seq data generated by Illumina sequencing. 

BALDR is based on the *de novo* assembly of RNA-Seq reads. It allows reconstructions using following methods:
1. IG-mapped_Unmapped (human and rhesus) - Assemble reads mapping to Ig loci + Unmapped reads [default for human]
2. FilterNonIG (rhesus)- Assemble reads after filtering those that match to non-Ig genes in the genome [default for rhesus]
3. Unfiltered (human and rhesus) - Use all reads for assembling transcripts and select Ig transcript models
4. IG-mapped_only (human and rhesus) - Assemble reads mapping to Ig loci
5. Recombinome-mapped (human) - Assemble reads mapping to the Ig recombinome
6. IMGT-mapped (human) - Assemble reads mapping to IMGT V(D)J and C sequences

## Installation (manual)

### Pre-requisites
1. [Trimmomatic 0.32](http://www.usadellab.org/cms/?page=trimmomatic)
2. [Trinity v2.3.2](https://github.com/trinityrnaseq/trinityrnaseq/wiki) (Newer versions are not compatible)
3. [bowtie2 2.3.0](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
4. [STAR v2.5.2b](https://github.com/alexdobin/STAR)
5. [samtools v1.3.1](http://www.htslib.org/download/)
6. [IgBLAST v1.6.1](https://www.ncbi.nlm.nih.gov/igblast/faq.html#standalone) (Newer versions are not compatible)
7. [seqtk 1.2](https://github.com/lh3/seqtk)
8. Perl 5

Install all the pre-requisites
Clone or download the BALDR package. 
```
cd BALDR
chmod +x BALDR
```
## Docker image

You can pull the image from DockerHub
```
docker pull bosingerlab/baldr
```

OR

You can use the Dockerfile to build an image. 
```
mkdir baldr_docker
cd baldr_docker
wget https://raw.githubusercontent.com/BosingerLab/BALDR/master/Dockerfile
docker build -t bosingerlab/baldr .
```

## Running BALDR

### STAR genome index

If the --STAR_index flag is not provided, BALDR will download and generate the genome index. This takes time and if a docker container is used, it may end up using a lot more space for the docker image. It is thus recommended that the STAR genome index be generated before running BALDR. A pre-built index can also be loaded into the shared memory which will significantly decrease the runtime. 

Human
```
mkdir -p STAR_GRCh38/STAR_GRCh38_index
cd STAR_GRCh38
wget ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget ftp://ftp.ensembl.org/pub/release-86/gtf/homo_sapiens/Homo_sapiens.GRCh38.86.gtf.gz
gunzip *.gz
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir STAR_GRCh38_index --genomeFastaFiles Homo_sapiens.GRCh38.dna.primary_assembly.fa --sjdbGTFfile Homo_sapiens.GRCh38.86.gtf --sjdbOverhang 100
```

Rhesus macaque
```
mkdir -p STAR_MacaM/STAR_MacaM_index
cd STAR_MacaM
wget https://www.unmc.edu/rhesusgenechip/MacaM_Rhesus_Genome_v7.fasta.bz2
bunzip2 MacaM_Rhesus_Genome_v7.fasta.bz2
wget https://www.unmc.edu/rhesusgenechip/RhesusGenomeUpload/MacaM_Rhesus_Genome_Annotation_v7.8.2.gtf
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir STAR_MacaM_index --genomeFastaFiles MacaM_Rhesus_Genome_v7.fasta --sjdbGTFfile MacaM_Rhesus_Genome_Annotation_v7.8.2.gtf --sjdbOverhang 100
```

### Loading genome index in the shared memory

Before running BALDR, it is recommended to load the genome index in the memory
```
STAR --genomeDir </path/to/STAR/index/folder> --genomeLoad LoadAndExit
```

When BALDR has been run for all cells, run the following command to clear the genome index from the shared memory
```
STAR --genomeDir </path/to/STAR/index/folder> --genomeLoad Remove
```

## Command line usage
```
Single-end:
./BALDR --single <file.fastq.gz> <options>

Paired-end:
./BALDR --paired <R1.fastq.gz,R2.fastq.gz> <options>

Options:
  --method       One or more reconstruction methods. For multiple methods, separte only by comma
  		 human: IG-mapped_Unmapped (default), Unfiltered, IG-mapped_only, IMGT-mapped, Recombinome-mapped 
  		 rhesus_monkey: FilterNonIG (default), Unfiltered, IG-mapped_only, IG-mapped_Unmapped
  --organism     human (default) or rhesus_monkey
  --trinity      Path for Trinity (e.g. ~/trinityrnaseq-Trinity-v2.3.2/Trinity) (required)
  --adapter      Path for the Trimmomatic adapter file (e.g. ~/Trimmomatic-0.36/adapters/NexteraPE-PE.fa) (required)
  --trimmomatic  Path for trimmomatic.jar file (e.g. ~/Trimmomatic-0.36/trimmomatic-0.36.jar) (required)
  --igblastn     Path for igblastn (e.g. ~/ncbi-igblast-1.6.1/bin/igblastn) (required)
  --STAR         Path for the STAR binary (required)
  --STAR_index   Path for the STAR aligner genome index
  --BALDR        Path for the BALDR directory (e.g. ~/BALDR) (required)
  --memory       Max memory for Trinity (default 32G)
  --threads      number of threads for STAR/bowtie2/Trinity (default 1)
  --version      Version
  --help         Print this help
```

## Running BALDR using the Docker image

```
# Single end
docker run -v </path/to/STAR/index>:/genome -v </path/to/fastq/files>:/data -w /data bosingerlab/baldr /home/tools/BALDR-master/BALDR --single /data/<file1_R1_001.fastq.gz> --trimmomatic /home/tools/Trimmomatic-0.38/trimmomatic-0.38.jar --adapter /home/tools/Trimmomatic-0.38/adapters/NexteraPE-PE.fa --BALDR /home/tools/BALDR-master --trinity /home/tools/trinityrnaseq-Trinity-v2.3.2/Trinity --memory 32G --threads 16 --STAR /home/tools/STAR-2.6.0c/bin/Linux_x86_64/STAR --STAR_index /genome --igblastn  /home/tools/ncbi-igblast-1.6.1/bin/igblastn

# Paired end
docker run -v </path/to/STAR/index>:/genome -v </path/to/fastq/files>:/data -w /data bosingerlab/baldr /home/tools/BALDR-master/BALDR --paired /data/<file1_R1_001.fastq.gz>,/data/<file1_R2_001.fastq.gz> --trimmomatic /home/tools/Trimmomatic-0.38/trimmomatic-0.38.jar --adapter /home/tools/Trimmomatic-0.38/adapters/NexteraPE-PE.fa --BALDR /home/tools/BALDR-master --trinity /home/tools/trinityrnaseq-Trinity-v2.3.2/Trinity --memory 64G --threads 32 --STAR /home/tools/STAR-2.6.0c/bin/Linux_x86_64/STAR --STAR_index /genome --igblastn  /home/tools/ncbi-igblast-1.6.1/bin/igblastn
```

## Output directories

The output is written in the working directory. The following folders are created:
  * **Trimmed** - contains trimmed reads output by Trimmomatic
  * **STAR** - contains output of STAR aligner
  * **IG-mapped_Unmapped/FilterNonIG/Unfiltered/IG-mapped/Recombinome-mapped/IMGT-mapped** - Folder created based on number of methods used
Each of the above folder contains:
    1. **Trinity**                       - output of Trinity assembly
    2. **IgBLAST**                       - output of IgBLAST
    3. **IgBLAST/tabular**               - (ii) parsed into a tabular format
    4. **IgBLAST_quant**                 - (iii) + number of reads mapped to the complete sequence and VDJ sequence
    5. **IgBLAST_quant_sorted**          - (iv) sorted by number of reads mapped to the complete sequence
    6. **IgBLAST_quant_sorted_filtered** - (v) filtered to retain only productive sequences and remove redundant models. 
                                            The final results are saved in this folder.       

## Aggregate results for all cells

The summary_IGH.pl and summary_IGKL.pl scripts in BALDR/lib can be used to aggregate results for all the cells. 
```
./summary_IGH.pl <path/to/IgBLAST_quant_sorted_filtered>
./summary_IGKL.pl <path/to/IgBLAST_quant_sorted_filtered>
```
This will generate a tab separated file with all filtered models for all cells. 

The columns of the Results_IGH_rank_all.txt file are as follows:

|Column number|Column|Description|
|--|:----|:------|
|1 |SampleID|Cell/Sample file name|
|2 |Chain|Heavy|
|3 |Method|Method used |
|4 |Rank|Rank sorted by # reads mapped|
|5 |Query|Transcript ID|
|6 |Error|Rare cases of misassembly where both IGH and IGL genes predicted|
|7 |Variable coords|V start to C start/V start to J end (if no C hit)|
|8 |Model length|Length of complete chain|
|9 |Bowtie2 count|Number of reads mapping to complete sequence|
|10|VDJ length|Length of VDJ region|
|11|VDJ Bowtie2 count|Number of reads mapping to VDJ sequence|
|12|V subject id|blast results for top V hit|
|13|V % identity||
|14|V alignment length||
|15|V mismatches||
|16|V gap opens||
|17|V gaps||
|18|V q. start||
|19|V q. end||
|20|V s. start||
|21|V s. end||
|22|V evalue||
|23|V bit score||
|24|J subject id|blast results for top J hit|
|25|J % identity||
|26|J alignment length||
|27|J mismatches||
|28|J gap opens||
|29|J gaps||
|30|J q. start||
|31|J q. end||
|32|J s. start||
|33|J s. end||
|34|J evalue||
|35|J bit score||
|36|C subject id|blast results for top C hit|
|37|C % identity||
|38|C alignment length||
|39|C mismatches||
|40|C gap opens||
|41|C gaps||
|42|C q. start||
|43|C q. end||
|44|C s. start||
|45|C s. end||
|46|C evalue||
|47|C bit score||
|48|Top V gene match|IgBLAST results|
|49|Top D gene match||
|50|Top J gene match||
|51|Chain type||
|52|stop codon||
|53|V-J frame||
|54|Productive||
|55|Strand||
|56|V end||
|57|V-D junction||
|58|D region||
|59|D-J junction||
|60|J start||
|61|CDR3||
|62|CDR3_nucleotide||
|63|CDR3_aminoacid||
|64|Orientation||
|65|Sequence||
|66|Sequence(+)|Sequence in the + orientation|
|67|VDJ sequence|VDJ sequence in the + orientation|

The columns of the Results_IGKL_rank_all.txt file are as follows:

|Column number|Column|Description|
|--|:----|:------|
|	1	|	Sample	|	Cell/Sample file name	|
|	2	|	Chain	|	Light	|
|	3	|	Method	|	Method used 	|
|	4	|	Rank	|	Rank sorted by # reads mapped	|
|	5	|	Query	|	Transcript ID	|
|	6	|	Error	|	Rare cases of misassembly where both IGH and IGL genes predicted	|
|	7	|	Variable coords	|	V start to C start/V start to J end (if no C hit)	|
|	8	|	Model length	|	Length of complete chain	|
|	9	|	Bowtie2 count	|	Number of reads mapping to complete sequence	|
|	10	|	VJ length	|	Length of VJ region	|
|	11	|	VJ Bowtie2 count	|	Number of reads mapping to VJ sequence	|
|	12	|	V subject id	|	blast results for top V hit	|
|	13	|	V % identity	|		|
|	14	|	V alignment length	|		|
|	15	|	V mismatches	|		|
|	16	|	V gap opens	|		|
|	17	|	V gaps	|		|
|	18	|	V q. start	|		|
|	19	|	V q. end	|		|
|	20	|	V s. start	|		|
|	21	|	V s. end	|		|
|	22	|	V evalue	|		|
|	23	|	V bit score	|		|
|	24	|	J subject id	|	blast results for top J hit	|
|	25	|	J % identity	|		|
|	26	|	J alignment length	|		|
|	27	|	J mismatches	|		|
|	28	|	J gap opens	|		|
|	29	|	J gaps	|		|
|	30	|	J q. start	|		|
|	31	|	J q. end	|		|
|	32	|	J s. start	|		|
|	33	|	J s. end	|		|
|	34	|	J evalue	|		|
|	35	|	J bit score	|		|
|	36	|	C subject id	|	blast results for top C hit	|
|	37	|	C %identity	|		|
|	38	|	C alignment length	|		|
|	39	|	C mismatches	|		|
|	40	|	C gap opens	|		|
|	41	|	C gaps	|		|
|	42	|	C q. start	|		|
|	43	|	C q. end	|		|
|	44	|	C s. start	|		|
|	45	|	C s. end	|		|
|	46	|	C evalue	|		|
|	47	|	C bit score	|		|
|	48	|	Top V gene match	|	IgBLAST results	|
|	49	|	Top J gene match	|		|
|	50	|	Chain type	|		|
|	51	|	stop codon	|		|
|	52	|	V-J frame	|		|
|	53	|	Productive	|		|
|	54	|	Strand	|		|
|	55	|	V end	|		|
|	56	|	V-J junction	|		|
|	57	|	J start	|		|
|	58	|	CDR3	|		|
|	59	|	CDR3_nucleotide	|		|
|	60	|	CDR3_aminoacid	|		|
|	61	|	Orientation	|		|
|	62	|	Sequence	|		|
|	63	|	Sequence(+)	|	Sequence in the + orientation	|
|	64	|	VJ sequence	|	VJ sequence in the + orientation	|


## Clonal assignment
... in progress

