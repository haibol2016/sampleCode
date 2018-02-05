#!/usr/bin/env perl
use warnings;
use strict;

################################ USAGE ##################################
# The input for this script is piped by 'cat */fastqc_data.txt' inside a
# directory where all FASTQC output are contained
# The output is a summary table of FASTQC results with rows for each sample
#########################################################################

my %fastqc=();
my %metrics=();

# start to scan the file "fastqc_data.txt" for a new fastq file  
my $start = 0;

my $fileName="";

sub fill_contents;
sub print_hash;


while (<>)
{
    chomp;
    my @items = split /\t/;
    
    if (/^##FastQC/ && !$start)
    {
        $start = 1;
    }
    elsif ($start && !/^##FastQC/)
    {
        if (/^Filename/)
        {
             $fileName = $items[1];
            
        }
        elsif (/^Encoding/ || /^Total Sequences/ || /^Sequences flagged as poor quality/ ||
               /^Sequence length/ || (/^>>/ && !/^>>END_MODULE/))
        {
             ## remove leading ">>"
             $items[0] =~ s/^>>//;
             #print "here!\n";
             $metrics{$items[0]} = $items[1];
        }
    }
    elsif($start && /^##FastQC/)  ## new file starts
    {
        #print Dumper(%metrics);
        fill_contents(\%metrics);
    }
}
fill_contents(\%metrics);


print_hash(\%fastqc);
        


## Create a hash of hash        
sub fill_contents
{
    %{$fastqc{$fileName}}= %{$_[0]};
    %metrics=();
    $fileName ="";
}


## print the all FASTQC results in a table, each row for one sample
        
sub print_hash
{
    my %hash = %{$_[0]};
    my $line = 1;
    
    for my $file (sort keys %hash)
    {
        if( $line==1)
        {
            my @header =("FileName", sort keys %{$hash{$file}});
            print join "\t", @header;
            print "\n";  
            $line++;
        }
        
        my @temp=();
        push @temp, $file;
        for my $metric (sort keys %{$hash{$file}})
        {
            push @temp, $hash{$file}->{$metric};
        }
        
        print join "\t", @temp;
        print "\n";
    }
}
        

