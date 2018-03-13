# ---------------------------------------------------------------------------------------------------
# HLE 10/08/2015
# Ajout pour capturer les evenements die
require "mega/error_handler.pl";
# ---------------------------------------------------------------------------------------------------

#=====================================================================================================
#                           INCLUDED MODULES
#=====================================================================================================

use Win32::GUI();
use Win32::File;
use Win32::FileOp;
use Win32::OLE;
use Win32::OLE qw(in with); 
use Win32::OLE::Const 'Microsoft ActiveX Data Objects';
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::Api;
use File::Basename;
use File::Path;
use File::Path qw(make_path);
use Date::Calc qw(:all);
use MIME::Lite;
use Net::SMTP;
use Mega::Exploit;
use POSIX qw/strftime/;

#=====================================================================================================
#                           PARAMETERS
#=====================================================================================================

my $Version    = shift;
my $Espace     = shift;
my $FlagEndTrt = shift;

if($FlagEndTrt ne"")
{ 
  setEHComputerNameAsFlag($FlagEndTrt);
}

my $returnCode;

if(!$Version || !$Espace || !$FlagEndTrt) {
  print "ERROR : the script $0 requires three arguments (version, espace, mode and flagEndTrt)\n";
  exit;
}


my $Log =  $ENV{'TEMP'} . "\\LaunchVM$Version$Espace.log";
my $ShortPath = "w:\\EA_Build_Log";
my $PathBats = $ShortPath."\\Bats";
Flag_IncrementCounter($FlagEndTrt, "ResetVM");
Flag_WriteFile($FlagEndTrt, "Log", $Log);    


my $VM =  Read_Ini($PathBats."\\VM-$Version-$Espace.ini", "VM","VM","");
$returnCode = ScriptFindAndExecute($Version, $Espace, "","exp_ResetVM_ps.ps1", "vp-dl-xyu3 $Log");

if($returnCode==0) { Flag_WriteStatus("Ok", $FlagEndTrt);}
else { Flag_WriteStatus("Ko", $FlagEndTrt);}
    


sub PrintTrace {
  my $LogFile = shift;
  my $Text = shift;
 
  my $Mess = "";

  if ($Text eq "." || $Text eq "\n"){
      $Mess = "$Text";
  } else {
    ($year,$mon,$mday) = Today();
    ($hour,$min,$sec) = Now();
    $DateT = sprintf("%2.2d/%2.2d/%4.4d %2.2d:%2.2d:%2.2d",$mday,$mon,$year,$hour,$min,$sec);
    $Mess = "   ($DateT) $Text " ;
  }
  open(LOG, ">>$LogFile");
  print "$Mess" ;
  print LOG "$Mess" ;
  close(LOG);
}


