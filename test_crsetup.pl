#-----------------------------------------------------------------------------------------------------
#  Pgm     : expcrsetup.pl
#  Objet   : Création et maj du master d'install (InstallShield X)
#  Auteurs : JYL
#-----------------------------------------------------------------------------------------------------
use Win32::GUI;
use Win32::OLE;
use Win32::OLE qw(in with); 
use Win32::OLE::Const 'Microsoft ActiveX Data Objects';
use Win32::FileOp;
use File::Basename;
use Date::Calc qw(:all);
use Mega::Exploit;
use Mega::Synergy::Sessions;



$projet = "W:\\temp\\HOPEX 2012\\mega_msi_2010.ism";



