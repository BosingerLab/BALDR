___
**Software material and data coming from IMGT server may be used for academic research only, provided that it is referred to IMGT®, and cited as "IMGT®, the international ImMunoGeneTics information system® http://www.imgt.org."** 
___

The IMGT human sequences were downloaded from http://www.imgt.org/vquest/refseqh.html on November 10, 2016.

Number of sequences:

F+ORF+in-frame P alleles including orphons
* IGHV - 350
* IGHD - 44
* IGHJ - 13
  
* IGKV - 108
* IGKJ - 9
  
* IGLV - 91
* IGLJ - 10

Constant gene artificially spliced exons sets
* IGHC - 55
* IGKC - 5
* IGLC - 13

A database of all possible recombined sequences from human V, J and C alleles obtained from IMGT was constructed based on a previously published method, [TraCeR] (https://www.nature.com/articles/nmeth.3800).20 N bases were added in the beginning of the sequence for alignment with leader sequence and D gene was replaced with 10 N bases. The resulting database comprised of 250,250 IGH (350 V, 13 J, 55 C), 11,830 IGL (91 V, 10 J, 13 C) and 4,860 IGK (108 V, 9 J, 5 C). A bowtie index was created for the heavy and light chain recombined sequences separately using using [bowtie2 version 2.2.9](https://github.com/BenLangmead/bowtie2/releases/tag/v2.2.9).
