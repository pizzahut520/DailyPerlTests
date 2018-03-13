use Win32::FileOp;



$file = shift;
$file_new = shift;



open(my $fh,"<", $file);
open(my $fo, ">", $file_new);

while (my $row = <$fh>) {
  if($row =~ /^MSI/){
    chomp $row;
    my $end    = substr $row, 32;
    print $fo $end."\n"; 
  }elsif($row =~ /^InstallShield/){
    chomp $row;
    my $end    = substr $row, 24;
    print $fo $end."\n"; 
  }else{
    chomp $row;
    print $fo $row."\n"; 
  }
  
}
