use Win32::File;
use Win32::FileOp;




my %h;
my $rep = "/home/lami20j";
opendir(REP,$rep) or die "E/S : $!\n";

while(defined(my $fic=readdir REP)){
  my $f="${rep}/$fic";
  if($fic=~/.*\.txt/){
    open FIC, "$f" or warn "$f E/S: $!\n";
    while(<FIC>){}
    $h{$f}=$.;
    close FIC;
  }
}