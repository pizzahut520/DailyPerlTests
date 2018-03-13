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


my $Version = shift;


my $file_ini = "w:\\tools\\versions.ini";


my $versiontye = Read_Ini($file_ini, "$Version","typeversionreference","");    # OK

if ($versiontye) {

	$Version = $versiontye;
}


print $Version;



