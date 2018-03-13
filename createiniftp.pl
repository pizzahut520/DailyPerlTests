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

$version = shift;
$espace = shift;

$ftp = init_connexion();
print $ftp->message;


$CWDRemote = "/Master_".$version."_".$espace;

$res = $ftp->cwd($CWDRemote);
print $ftp->message;

@file_list = $ftp->dir();

print @file_list;



my $inifile = "c:\\temp\\ftpmasterdate.ini";

foreach my $file (@file_list){
	# print $file."\n";
	
	@split = split (/\s+/, $file);
	my $file_name = $split[8];
	my $date = $split[5]."-".$split[6]."-".$split[7];
	print "Filename = $file_name modifdate = $date\n";
	Write_Ini($inifile, "$version.$espace","$file_name", $date);
}

#-------------------------------------------------
sub init_connexion
{
    my $FtpHost = 'downloadmega.com'; # hostname
    my $UserName = 'uw3xk93wya82'; #user
    my $Pass = 'pb457w3v19'; #pass     pb457w3v19

    my $ftp = Net::FTP->new($FtpHost, Timeout => 180, Port => 21 , Passive => 1 ) || return die;
    $ftp->login($UserName, $Pass) || return die;
    $ftp->binary();
    return $ftp;
}



