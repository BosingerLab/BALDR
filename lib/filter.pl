#!/usr/bin/perl -w
use strict;

my $file = $ARGV[0];
my $out_path = $ARGV[1];

system "mkdir -p $out_path/IgBLAST_quant_sorted_filtered";

open IN,"$out_path/IgBLAST_quant_sorted/$file" or die $!;
open OUT,">$out_path/IgBLAST_quant_sorted_filtered/$file\.filtered" or die $!;

my %results;

my %done;

while(my $ln =<IN>)
{
  my @arr = split("\t",$ln);

  if( ($file=~/IGH/ && ($ln=~/IGK/ || $ln=~/IGL/)) || ($file=~/IGKL/ && $ln=~/IGH/) ) 
  {
    print "CHECK: $file\t$arr[0]\t$arr[3]\tPredicted IGK/IGL for a heavy chain\n";
    next;
  }
 
  my ($len,$bt2,$vdjlen,$vdjbt2,$c,$v,$d,$j,$stop,$inframe,$prod,$cdr3,$varseq,$clonotype);

  $len = $arr[3];
  $bt2 = $arr[4];
  $vdjlen = $arr[5];
  $vdjbt2 = $arr[6];
  $c = $arr[31];

  if($file=~/IGH/)
  {
    $v = $arr[43];
    $d = $arr[44];
    $j = $arr[45];
    $stop = $arr[47];
    $inframe = $arr[48];
    $prod = $arr[49];
    $cdr3 = $arr[58];
    $varseq = $arr[62];
    $clonotype = "$v~$d~$j~$cdr3";
  }
  elsif($file=~/IGKL/)
  {
    $v = $arr[43];
    $j = $arr[44];
    $stop = $arr[46];
    $inframe = $arr[47];
    $prod = $arr[48];
    $cdr3 = $arr[55];
    $varseq = $arr[-1];
    $clonotype = "$v~$j~$cdr3";
  } 
    
  if($vdjbt2 eq "-"){$vdjbt2 = 0;}

  if($prod eq "Yes" && !($done{$clonotype}) ) 
  {
    print OUT $ln;
    $done{$clonotype} = 1;
  } 

  #if($vdjbt2 > 0)
  #{
  # if($prod eq "Yes" && !($done{$clonotype}) ) 
  # {
  #   print OUT $ln;
  #   $done{$clonotype} = 1;
  # } 
  #}
}
print "Results written to $out_path/IgBLAST_quant_sorted_filtered/$file\.filtered\n";

