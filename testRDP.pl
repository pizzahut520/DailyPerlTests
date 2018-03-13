# stopVMParis
my $rdpTemplate = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\RemoteTemplate.rdp";
my $rdpStop = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\ExpStopVM.rdp";
open(FILE, "<$rdpTemplate") || die "File not found";
my @lines = <FILE>;
close(FILE);

my @newlines;
foreach(@lines) {
   print $_."\n";
   $_ =~ s/COMMANDENAME/ExpStopVM/g;
   push(@newlines,$_);
}

open(FILE, ">$rdpStop") || die "File not found";
print FILE @newlines;
close(FILE);



# unlink $rdpStop;

