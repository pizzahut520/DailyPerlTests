#! /usr/bin/perl
use strict;
use warnings;

use XML::Simple;
use Data::Dumper;
use XML::Dumper;







# my $parser = XML::Simple->new(KeepRoot => 1);

my $xml_file = "C:\\temp\\mega_msi_2010.ism";
my $out_put = $xml_file."_out";

open(MYFILE,"$xml_file");
my $modif=0;
open(OUTPUT,">$out_put");

while(<MYFILE>){
	my $line = $_;
	
	if ($line =~ "table name=\"ISLogicalDiskFeatures\""){
		$modif = 1;
		
	}
	if($modif eq 1 && $line =~ "</table>"){
		$modif = 0;
		
	}
	if($modif eq 1){
		
		$line =~ s/<td>0<\/td><\/row>/<td>1<\/td><\/row>/g; 
		
	}
	print OUTPUT $line;	
	
	
}
	
close (OUTPUT);
close (MYFILE); 

unlink $xml_file;
rename $out_put, $xml_file;





