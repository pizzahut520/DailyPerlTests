#
use warnings;
use strict;
use Win32::Api;
use Getopt::Long;
use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );
use Win32::File;
use Win32::FileOp;
use File::DosGlob 'glob';
use File::Basename;
use File::Path;
use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );
use Mega::Logger;
use Mega::Exploit;
use MIME::Lite;
use Net::SMTP;


my $uas_package = "R:\\Transfer\\HIP\\UAS.zip";
my $unzip_path = "w:\\temp\\xyu\\UAS_unzip";


my $WinzipExe = "c:\\bat\\wzunzip.exe";

print "Decompression de $uas_package vers $unzip_path \n";
    system("$WinzipExe -o -d $uas_package $unzip_path");

