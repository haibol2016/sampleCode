#!/usr/bin/env perl

use warnings;
use strict;
use Getopt::Long 'HelpMessage';

## get command line options and check their type
GetOptions(
  "gtf=s" => \my $gtf,
  'help'  =>  sub { HelpMessage(0) },
) or HelpMessage(1);

# die unless we got the mandatory argument
HelpMessage(1) unless $gtf;

my $gene_id;
my $transcript_id  = "";
my $blockCount;
my @blockSizes;
my @blockStarts;
my ($thickStart, $thickEnd, $strand);
my ($chr, $chrStart, $chrEnd);
my $start = 0;

sub read_transcript;
sub print_bed;

open (my $gtf_fh, "<", $gtf) or die $!;
while (<$gtf_fh>)
{
    next if (/^#/);
    chomp;
    
    ## split lines using delimiters (tab, semicolon, or a single space)
    my @line=split /\t|; /;
    
    if ($line[2] =~ m/transcript/ && !$start)
    {
        ($chr, $chrStart, $chrEnd, $transcript_id, $gene_id, $thickStart, $thickEnd, $strand, $start) = read_transcript(@line);
    }
    elsif($line[2] =~ m/exon/)
    {
       $blockCount++;
       my $blockSize = $line[4] - $line[3] + 1;
       push @blockSizes, $blockSize;
       my $blockStart = $line[3] - 1 - $thickStart;
       push @blockStarts, $blockStart;   
    }
    elsif ($line[2] =~ m/transcript/ && $start)
    {
        ## print a line of BED
        print_bed();
        
        ## reset @blockSizes, @blockStarts and $blockCount
        @blockSizes = ();
        @blockStarts = ();
        $blockCount = 0;
        
        ## pasre a line of GTF
        ($chr, $chrStart, $chrEnd, $transcript_id, $gene_id, $thickStart, $thickEnd, $strand, $start) = read_transcript(@line);
    }
}
## print the last line of BED
print_bed();
close $gtf_fh;

## subroutin to parse a line of GTF
sub read_transcript
{
    my @line=@_;
    my $chr = $line[0]; 
    my $transcript_id = ($line[10] =~ m/transcript_id \"([^"]+)/)[0];
    my $gene_id = ($line[8] =~ m/gene_id \"([^"]+)/)[0];
    my ($thickStart, $thickEnd, $strand) = ($line[3] - 1, $line[4], $line[6]);
    my ($chrStart, $chrEnd) = ($thickStart, $thickEnd);
    my $start = 1;
    ($chr, $chrStart, $chrEnd, $transcript_id, $gene_id, $thickStart, $thickEnd, $strand, $start);   
}

## subroutin to print a line of BED
sub print_bed
{
        my @bedline = ($chr, $chrStart, $chrEnd, $transcript_id, 0, $strand, $thickStart, $thickEnd, 0, $blockCount);
        print join "\t", @bedline;
        print "\t";
        
        print join ",", @blockSizes;
        print "\t";
        
        print join ",", @blockStarts;
        print "\n";     
}



=pod

=head1 NAME

gtf2bed - convert genome annotation from the GTF to BED format

=head1 DESCRIPTION

This is a simple utility to convert genome annotation from the GTF to BED format.

=head1 SYNOPSIS

  Options:
  --gtf, -g       A name of the GTF file for genome annotation
  --help,-h       Print help message
  
  Example uasge: perl gtf2bed  XXX.gtf > XXX.bed

=head1 VERSION

0.01

=head1 AUTHOR

Haibo Liu (Haibo.Liu@umassmed.edu)

=cut
