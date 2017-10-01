#!/usr/bin/perl -w
use strict;

my @files = <$ARGV[0]>;
foreach my $f(@files)
{
  system "sort -k5,5nr $f > sorted/$f\.sorted";
}

