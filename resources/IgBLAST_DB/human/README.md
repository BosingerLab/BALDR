___
**Software material and data coming from IMGT server may be used for academic research only, provided that it is referred to IMGT®, and cited as "IMGT®, the international ImMunoGeneTics information system® http://www.imgt.org". For any other use please contact Marie-Paule Lefranc Marie-Paule.Lefranc@igh.cnrs.fr. For information on IMGT® copyright, warranty disclaimer, liability, endorsement, please see http://www.imgt.org/about/warranty.php** 
___


The IMGT human sequences were downloaded from http://www.imgt.org/vquest/refseqh.html on November 10, 2016

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
___

The [IgBLAST](https://www.ncbi.nlm.nih.gov/igblast/) database was created as follows:

The V and J sequences for heavy and the light chains were combined to get a file each for V and J sequences.  

edit_imgt_file.pl script in the IgBLAST package was used to modify the IMGT files.
```
edit_imgt_file.pl human_IG_V.fa > human_IG_V
edit_imgt_file.pl human_IG_D.fa > human_IG_D
edit_imgt_file.pl human_IG_J.fa > human_IG_J
```

makeblastdb tool from NCBI blast 2.6.0+ suite was used to create the IgBLAST databases:
```
makeblastdb -parse_seqids -dbtype nucl -in human_IG_V
makeblastdb -parse_seqids -dbtype nucl -in human_IG_D
makeblastdb -parse_seqids -dbtype nucl -in human_IG_J
```
___
