
use warnings;
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
use Mega::FileMngt;
use Mega::Logger;
use Mega::Exploit;
use MIME::Lite;
use Net::SMTP;
use File::Glob 'bsd_glob';
use Mega::Zorglub;

my $Version    = shift;
my $Espace     = shift;


$File_Ini = "w:/tools/Versions.ini";
my $PathDemo       = Read_Ini($File_Ini, "$Version","PathDemo","");       # OK


my $workspace_mol = $PathDemo.".".$Espace;
my $path_final_mol = $workspace_mol."\\Update";

printf $workspace_mol;
printf $path_final_mol;


my $path_ancien_mol = $workspace_mol."\\Upgrade";
my $path_nextCP_mol = $workspace_mol."\\Mgr";

CopyEx("$path_ancien_mol\\*.*" => "$path_final_mol",FOF_FILESONLY|FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);
CopyEx("$path_nextCP_mol\\Upgrade.mol" => "$path_final_mol",FOF_FILESONLY|FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);
