___
**Software material and data coming from IMGT server may be used for academic research only, provided that it is referred to IMGT®, and cited as "IMGT®, the international ImMunoGeneTics information system® http://www.imgt.org."** 
___

The IMGT rhesus monkey sequences were downloaded from http://www.imgt.org/vquest/refseqh.html on January 27, 2017

Number of sequences:

F+ORF+in-frame P alleles including orphons
* IGHV - 23
* IGHD - 32
* IGHJ - 8
  
* IGKV - 103
* IGKJ - 5
  
* IGLV - 99
* IGLJ - 6

___

The [IgBLAST](https://www.ncbi.nlm.nih.gov/igblast/) database was created as follows:

The V and J sequences for heavy and the light chains were combined to get a file each for V and J sequences.  

edit_imgt_file.pl script in the IgBLAST package was used to modify the IMGT files.
```
edit_imgt_file.pl rhesus_IG_V.fa > rhesus_IG_V
edit_imgt_file.pl rhesus_IG_D.fa > rhesus_IG_D
edit_imgt_file.pl rhesus_IG_J.fa > rhesus_IG_J
```

makeblastdb tool from NCBI blast 2.6.0+ suite was used to create the IgBLAST databases:
```
makeblastdb -parse_seqids -dbtype nucl -in rhesus_IG_V
makeblastdb -parse_seqids -dbtype nucl -in rhesus_IG_D
makeblastdb -parse_seqids -dbtype nucl -in rhesus_IG_J
```
___
