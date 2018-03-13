# ---------------------------------------------------------------------------------------------------
# HLE 10/08/2015
# Ajout pour capturer les evenements die
require "mega/error_handler.pl";
# ---------------------------------------------------------------------------------------------------

#=====================================================================================================
#                           INCLUDED MODULES
#=====================================================================================================

use Win32::FileOp;
use Win32::OLE;
use MIME::Lite;
use Net::SMTP;
use Date::Calc qw(:all);
use Time::gmtime;
use Mega::Exploit;
use File::Basename;
use POSIX qw/strftime/;
use Sys::Hostname;
use Mega::FileMngt;
use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );

my $Version = 785;
my $Espace = "int";


my $versions_ini = "w:/tools/versions.ini";
my $wa_path = Read_Ini($versions_ini, "$Version","pathorigine","");  #= > x:\wa

my $setup_composant_rewrite = $wa_path."\\code-$Version.$Espace\\code\\exethird\\rewrite_amd64_en-US.msi";


$install_cmd = "msiexec /package $setup_composant_rewrite /passive /lewv \"c:\\temp\\megaInstallLog_785_int.log\" ";
if(systemWithCheck($install_cmd)==0){
  Mega::Exploit::PrintTrace($Log, "Installation rewrite_amd64_en.msi-> OK \n");
  Flag_WriteStatus("Ok", $FlagEndTrt);
} else {
  Mega::Exploit::PrintTrace($Log, "Echec de Installation rewrite_amd64_en.msi -> KO \n");
  Flag_WriteStatus("Ko", $FlagEndTrt);
}
