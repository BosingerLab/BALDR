#!/usr/bin/perl -w
use strict;

my $igblast_file = $ARGV[0];
my $sequence_file = $ARGV[1];

$igblast_file=~/(.*)\/(.*)\/(.*).blastout/;

my $outfile_path = $1; 
my $igblast_results_path = "$1/$2";
my $sample = $3;

system "mkdir -p $igblast_results_path/tabular";

system "mkdir -p $outfile_path/Quantification/full/counts";
system "mkdir -p $outfile_path/Quantification/full/Log";
system "mkdir -p $outfile_path/Quantification/full/index";

system "mkdir -p $outfile_path/Quantification/VDJ/counts";
system "mkdir -p $outfile_path/Quantification/VDJ/Log";
system "mkdir -p $outfile_path/Quantification/VDJ/index";

#print "$outfile_path $igblast_path\n";

my %sequences;

open IN,"$sequence_file" or die "Cannot open $sequence_file";
$/=">";
my @seqs = <IN>;
close IN;
$/="\n";
foreach my $record(@seqs)
{
  my @arr = split("\n",$record);
  my $head = shift @arr;
  $head=~/(\S+)/;
  $head = $1;
  my $seq = join "",@arr;
  $seq=~s/\>//;
  $sequences{$head} = $seq;  
}
close IN;

  
open IN,"$igblast_file" or die $!;
open OUT,">$igblast_results_path/tabular/$sample\.igblast_tabular" or die $!;

#print OUT "Query\tError\tVDJ coords\tV subject id\tV % identity\tV alignment length\tV mismatches\tV gap opens\tV gaps\tV q. start\tV q. end\tV s. start\tV s. end\tV evalue\tV bit score\tJ subject id\tJ % identity\tJ alignment length\tJ mismatches\tJ gap opens\tJ gaps\tJ q. start\tJ q. end\tJ s. start\tJ s. end\tJ evalue\tJ bit score\tC subject id\tC % identity\tC alignment length\tC mismatches\tC gap opens\tC gaps\tC q. start\tC q. end\tC s. start\tC s. end\tC evalue\tC bit score\tTop V gene match\tTop J gene match\tChain type\tstop codon\tV-J frame\tProductive\tStrand\tV end\tV-J junction\tJ start\tCDR3\tCDR3_nucleotide\tCDR3_aminoacid\tOrientation\n";    
#print OUT "Query\tError\tVDJ coords\tV subject id\tV % identity\tV alignment length\tV mismatches\tV gap opens\tV gaps\tV q. start\tV q. end\tV s. start\tV s. end\tV evalue\tV bit score\tJ subject id\tJ % identity\tJ alignment length\tJ mismatches\tJ gap opens\tJ gaps\tJ q. start\tJ q. end\tJ s. start\tJ s. end\tJ evalue\tJ bit score\tC subject id\tC % identity\tC alignment length\tC mismatches\tC gap opens\tC gaps\tC q. start\tC q. end\tC s. start\tC s. end\tC evalue\tC bit score\tTop V gene match\tTop J gene match\tChain type\tstop codon\tV-J frame\tProductive\tStrand\tV end\tV-J junction\tJ start\tCDR3\tCDR3_nucleotide\tCDR3_aminoacid\tOrientation\n";    

open OUT1,">$outfile_path/Quantification/VDJ/$sample\.VDJ.fa" or die $!;
open OUT2,">$outfile_path/Quantification/full/$sample\.full.fa" or die $!;

$/="# IGBLASTN";
my @results = <IN>;
$/="\n";
close IN;
foreach my $result(@results)
{
  my $query;
  my $vdj;
  my $junctions;
  my $cdr3;
  my %igblast;
  my $orientation = "+";
  my $v_start = -1;
  my $j_end = -1;
  my $c_start = -1;

  #print "$result\n";

  my @lines = split("\n",$result);
  for(my $i=0; $i<scalar(@lines);$i++)
  {
    if($lines[$i]=~/# 0 hits found/)
    {
      last;
    }
    if($lines[$i]=~/Note that your query represents the minus strand of a V gene/)
    {
      $orientation = "-";
    }
    if($lines[$i]=~/Query: (\S+)/)
    {
      $query = $1;
    }
    if($lines[$i]=~/V-\(D\)-J rearrangement summary for query sequence/)
    {
      $i++;
      chomp $lines[$i];
      $vdj = $lines[$i];
    }
    if($lines[$i]=~/V-\(D\)-J junction details based on top germline gene matches/)
    {
      $i++;
      chomp $lines[$i];
      $junctions = $lines[$i];
    }
    if($lines[$i]=~/Sub-region sequence details \(nucleotide sequence\, translation\)/)
    {
      $i++;
      chomp $lines[$i];
      $cdr3 = $lines[$i];
    }
    my @arr = split("\t",$lines[$i]);

    # Get alignments results for top hit for V, J and C

    if(scalar(@arr) > 12)
    {
      if($arr[0] eq 'V')
      {
        if(!($igblast{'V_evalue'}))
        {
          $igblast{'V_evalue'} = $arr[12];
          $v_start = $arr[8];    
          chomp $lines[$i];
          $igblast{'V_results'} = $lines[$i];
        }
        
      }
      if($arr[0] eq 'J')
      {
        if(!($igblast{'J_evalue'}))
        {
          $igblast{'J_evalue'} = $arr[12];
          $j_end = $arr[9];
          chomp $lines[$i];
          $igblast{'J_results'} = $lines[$i];
        }
      }
      if($arr[0] eq 'N/A')
      {
        if(!($igblast{'C_evalue'}))
        {
          $igblast{'C_evalue'} = $arr[12];
          $c_start = $arr[8];
          chomp $lines[$i];
          $igblast{'C_results'} = $lines[$i];
        }
      }     
    }
  }
  
  # Reformat => change space to tabs
  my $v;
  my $j;
  my $c;

  if(!($igblast{'V_evalue'}))
  {
    $igblast{'V_evalue'}=1;
    $v="-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-";
  }
  else
  {
    my @varr = split(" ",$igblast{'V_results'});
    $v= join "\t",splice(@varr,2);
  }

  if(!($igblast{'J_evalue'}))
  {
    $igblast{'J_evalue'}=1;
    $j="-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-";
  }
  else
  {
    my @jarr = split(" ",$igblast{'J_results'});
    $j = join "\t",splice(@jarr,2);
  }

  if(!($igblast{'C_evalue'}))
  {
    $igblast{'C_evalue'} = '-';
    $c="-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-";
  }
  else
  {
    my @carr = split(" ",$igblast{'C_results'});
    $c = join "\t",splice(@carr,2);
  }

  # Consider IG chain only if evalue for V < 0.001 or J < 0.001. EIther chosen for cases when models may have been incomplete

  if($igblast{'V_evalue'} < 0.001 || $igblast{'J_evalue'} < 0.001)
  {
    
    # Get sequence in the + orientation

    my $plus_orient="";
    
    if($orientation eq "+")
    {
      $plus_orient = $sequences{$query};
    }
    elsif($orientation eq '-')
    {
      $plus_orient = reverse($sequences{$query});
      $plus_orient =~ tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
    }

    
    # Get VDJ sequence. The end of VDJ sequence is preferable considered as the C gene start position. 
    # If an appropriate C start positions is not predicted, then the J gene end position is used

    my $flag = "-"; # Rare cases both IGH and IGL in a chain. This flag is to check this misassembly 

    my $var_start = $v_start - 1; # 0 based position used to get VDJ sequence
    my $var_len;
    my $vdj_seq = ""; # VDJ sequence
    my $var_coords;

    if($c_start > 0)
    {
      if($c_start < $v_start && ($v=~/IGH/ && ($c=~/IGK/ || $c=~/IGL/) || $c=~/IGH/ && ($v=~/IGK/ || $v=~/IGL/))) 
      {
        $flag = "ERROR-H&L";
        $vdj_seq = "ERROR";
        $var_coords = "$v_start-$c_start";
      } 
      else
      {
        $var_len = $c_start - $v_start; # Do not include constant; not adding 1
        $vdj_seq = substr($plus_orient,$var_start,$var_len);
        $var_coords = "$v_start-$c_start"; 
      }
    }
    elsif($j_end > 0 || ($var_len && $var_len > 500) )# > 500 since in rhesus if C start is not exact wrong VDJ
    {
      $var_len = ($j_end - $v_start) + 1;
      $vdj_seq = substr($plus_orient,$var_start,$var_len);
      $var_coords="$v_start-$j_end";
    } 
    else
    {
      $vdj_seq = substr($plus_orient,$var_start);
      $var_coords="$v_start-";
    }
    if(!($vdj)){$vdj="-";}
    if(!($junctions)){$junctions="-";}
    if(!($orientation)){$orientation="-";}
    if(!($sequences{$query})){$sequences{$query}="-";}
    if(!($plus_orient)){$plus_orient="-";}
    if(!($cdr3)) {$cdr3 = "-\t-\t-";}
    if(!($c)){$c="-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-\t-";}

    
    print OUT "$query\t$flag\t$var_coords\t$v\t$j\t$c\t$vdj\t$junctions\t$cdr3\t$orientation\t$sequences{$query}\t$plus_orient\t$vdj_seq\n";
    print OUT1 ">$query\n$vdj_seq\n";
    print OUT2 ">$query\n$sequences{$query}\n";
  }
}
