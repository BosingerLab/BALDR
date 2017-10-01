#!/usr/bin/perl -w
use strict;

my $file_name = $ARGV[0];
my $out_path = $ARGV[1];


my %bt2_full;
my %bt2_VDJ;

system "mkdir -p $out_path/IgBLAST_quant";
  
open OUT,">$out_path/IgBLAST_quant/$file_name.igblast_tabular.quant" or die $!;

my $counts_full = "$out_path/Quantification/full/counts/$file_name\_full_bt2_numreadsmapped";

open IN,$counts_full or die "$counts_full not found\n";
while(my $ln = <IN>)
{
  chomp $ln;
  $ln=~/(\d+)\s+(\S+)/;
  $bt2_full{$2} = $1;  
}
close IN;


my $counts_VDJ = "$out_path/Quantification/VDJ/counts/$file_name\_VDJ_bt2_numreadsmapped";
open IN,$counts_VDJ or die "$counts_VDJ not found\n";
while(my $ln = <IN>)
{
  chomp $ln;
  $ln=~/(\d+)\s+(\S+)/;
  $bt2_VDJ{$2} = $1;
}
close IN;


my $igblast_tabular = "$out_path/IgBLAST/tabular/$file_name\.igblast_tabular";
open IN,"$igblast_tabular" or die "$igblast_tabular not found\n";
while(my $ln = <IN>)
{  
  chomp $ln;
  
  my @arr = split(" ",$ln);
  my $len = length($arr[-2]);
  my $vdj_len;
  
  if($arr[-1] eq "ERROR")
  {
    $vdj_len = "-";
  }
  else
  {
    $vdj_len = length($arr[-1]);
  }
  
  if(!($bt2_full{$arr[0]})) {$bt2_full{$arr[0]} = '-';}
  
  if(!($bt2_VDJ{$arr[0]})) {$bt2_VDJ{$arr[0]} = '-';}
  
  splice(@arr, 3, 0,$len,$bt2_full{$arr[0]});
  
  splice(@arr, 5, 0,$vdj_len,$bt2_VDJ{$arr[0]});
  
  my $new = join "\t",@arr;
      
  print OUT "$new\n";
}
close IN;
close OUT;


