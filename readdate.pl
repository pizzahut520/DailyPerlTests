
use Win32::File;
use Win32::FileOp;
use Net::FTP;
use Net::Ping;
use MIME::Lite;
use Net::SMTP;
use Cwd;
use File::Path;
use File::stat;
use File::Basename;
use Getopt::Long;
use Mega::Exploit;

$Version = "740";
$Espace = "int";
	my $filedate_ini = "c:\\temp\\ftpmasterdate.ini";
	my $localdate = Read_Ini($filedate_ini,"$Version.$Espace","master740int.z02","");
	print $localdate;
	
	
	
	
	if (-e "c:\\DailyDownload\\int740\\master740int.z16") {print "cccc";}