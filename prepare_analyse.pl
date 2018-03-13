


my $file_inter = "c:\\temp\\scriptcall_analyse.txt";
my $w_tools = "w:\\tools\\";
opendir(DIR,$w_tools);
my @files = readdir(DIR);
closedir(DIR);

open(RES,">$file_inter") or die "Impossible d'ouvrir le fichier: $!";
foreach(@files){
  
  if($_ =~ m/\.pl/ || $_ =~ m/\.bat/ ){
	print RES lc($_).":\n";
  }
  
}
close(RES);