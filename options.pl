#!/usr/bin/perl -w
 
# a perl getopts example
# alvin alexander, <a href="http://www.devdaily.com" title="http://www.devdaily.com">http://www.devdaily.com</a>
 

$version = $ARGV[0];
$espace =  $ARGV[1];
 
 

while (my $option = shift @ARGV)	{
	
	if($option eq "-t")
	 {
	 $tasks = shift @ARGV;
	 print $tasks;
	 }
	 
	if($option eq "-d")
	 {$projets = shift @ARGV;print $projects;}
}


print "\n version= $version \n espace=$espace \n tasks = $tasks \n projets = $projets";