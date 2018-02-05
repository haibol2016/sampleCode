#!/usr/bin/env perl
use warnings;
use strict;
use Getopt::Long 'HelpMessage';

## get command line options and check their type
GetOptions(
  "fastq=s" => \my $fastq,
  "metadata=s" =>  \my $metadata,
  'help'  =>  sub { HelpMessage(0) },
) or HelpMessage(1);

# die unless we got the mandatory argument
HelpMessage(1) unless $fastq && $metadata;

## hash %meta: sample IDs as keys and barcodes as values
my %meta = ();

## file handle hash
my %fhs = ();

## flag to record whether a read is being read
my $start = 0;

## barcode of current reads
my $cur_barcode = "";

sub split_print;
sub close_file;


## parse sample IDs and barcodes into  hash %meta
open(my $meta_fh, "<", $metadata) or die $!;

while (<$meta_fh>)
{
    chomp;
    my @items = split /\t| /;
    
    ## remove spaces in sample IDs
    $items[0] = ($items[0] =~ s/\s+/_/g);
 
    ## sanity check on barcode sequences
    if ($items[1] !~ /[^ATCG]/)
    {
        $meta{$items[0]} = $meta{$items[1]};
    }
    else
    {
        die "Wrong barcode sequences containing unkown bases!"
    }
}
close $meta_fh;

## for reads with ambiguious barcode sequence
$meta{"ambiguious"} = "ambiguious";

## parse fastq file

open(my $fastq_fh, "<", $fastq) or die $!;

#### read 1 file
if ($fastq =~ /_R1_/)
{
    ## hash of filehandles used, need {} to de-reference when print
    for my $key (keys %meta)
    {
         open($fhs{$meta{$key}}, ">", $fastq.$key."_R1.fq") 
    }
    while (<$fastq_fh>)
    {
        split_print($_);
    }
}
else  #### read 2 file
{
   for my $key (keys %meta)
    {
         open($fhs{$meta{$key}}, ">", $fastq.$key."_R2.fq") 
    }
    while (<$fastq_fh>)
    {
        split_print($_);
    }
}
close $fastq_fh;
close_file();

#### print a read to a file specified by the barcode
sub split_print
{    
    my $line= shift @_;
    
    ## check whether the lise is the first line of a read
    if ($. % 4 == 1)
    {   
        if (!$start && $line=~ m/[12]:N:0:([ATCG]{6})/)
        {
            $cur_barcode = $1;
            $1="";
            if (exists ($fhs{$cur_barcode}))
            {
                ## hash of filehandles used, need {} to de-reference when print
                print {$fhs{$cur_barcode}} $line;                
            }
            else
            {
                $cur_barcode = "other";
                print {$fhs{$cur_barcode}} $line; 
            }
            $start = 1; 
        }
    }
    elsif ( $start && ($. % 4 == 2 || $. % 4 == 3))
    {
        print {$fhs{$cur_barcode}} $line;
    }
    elsif ( $start && $. % 4 == 0)  ## last line
    {
        print  {$fhs{$cur_barcode}} $line;
        $start = 0;
    }   
}

## close file handles
sub close_file
{
    foreach my $key(keys %fhs)
    {
        close($fhs{$key});
    }
}

=pod

=head1 NAME

splitFastqByBarcode - Split a single uncompressed fastq file which is from a multiplexing Illumina high-throughput
                         sequencing lane into separate files based on barcode sequences kept in fastq header


=head1 DESCRIPTION

This is a simple utility to split fastq files from a multiplexing Illumina sequencing lane. The edit distance (Levenshtein Distance) algorithm
can be incorporate to resolve ambiguious read assignment for better performance.

=head1 SYNOPSIS

  Options:
  --fastq,-f      A file name for an uncompressed fastq (required)
  --metadata,-m   A file name for a txt file with sample IDs as column 1 and the corresponding barcode sequence as coulmn 2 (required). 
  --help,-h       Print help message
  
  Example uasge: perl splitFastqByBarcode.pl --fastq  xxx_R1_1.fastq  --metadata  sample.info.txt

=head1 VERSION

0.01

=head1 AUTHOR

Haibo Liu (Haibo.Liu@umassmed.edu)

=cut

