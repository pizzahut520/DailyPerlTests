use File::Copy;

use Win32::File;
use Win32::FileOp;


use File::Copy qw(move);


    
# my $Fournitures = "w:\\750\\fournitures";
# my $dir = $Fournitures ."\\framework";




my $dir = "W:\\763\\Master_Internal_Controls\\MGL\\AllRelease\\Files";
chdir($dir);
opendir(DIR,$dir);

foreach my $file (readdir(DIR)) {
print $file;
	move($file, "SystemDb_".$file);
}


