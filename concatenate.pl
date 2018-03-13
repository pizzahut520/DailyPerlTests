use File::Copy;

use Win32::File;
use Win32::FileOp;


my $fileA = "C:\\temp\\framework\\ERM\\ERM - 10 - Technical\\Files\\SystemDB.mgr";
my $fileB = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\b.txt";


#OPEN FILE A.txt FOR APPENDING (CHECK FOR FAILURES)
open ( B, ">", $fileB ) 
    or die "Could not open file A.txt: $!";

#OPEN FILE B.txt for READING (CHECK FOR FAILURES)
open ( A, "<", $fileA ) 
    or die "Could not open file B.txt: $!";


while ( my $line = <A> ) {
  print B $line;
}