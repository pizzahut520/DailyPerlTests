
$wa="C:/temp";
opendir (my $FhRep, $wa)
                or die "Impossible d'ouvrir le repertoire $wa\n";
my @Contenu = grep { /\.txt$|\.log$/ } readdir($FhRep);

foreach $f (@Contenu){
  print $f."\n";

}