# ---------------------------------------------------------------------------------------------------
# HLE 10/08/2015
# Ajout pour capturer les evenements die
require "mega/error_handler.pl";
# ---------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------
# HGT / XYU 6/10/2011 
# Ajout pour tracer les scripts appelés
system("w:\\tools\\scripttrace.pl $0");
# ---------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
#  Pgm     : expmasterx.pl
#  Objet   : Procedure Exploitation 32 bits.  Generation Master InstallShield X
#            Derniers tuning du ISM, puis creation du master
#  Auteurs : JYL, LBN
#
#           Master
#           Version
#           Espace (dev int ou tst)
#           Mode (debug ou release)
#           Media (_Default ou ....)
#           Copie sur integr (0 1)
#              si copie alors les deux paramètres suivants sont traités
#                       Lancement installation (0 1)
#                       Copie sur le FTP   (0 1)
#
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
# 28/11/2011 HGT
# Ajout du Media dans le mail d'échec de construction.
#-----------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# HGT 10/1/2012
# Mise en place d'un flag stop
# ---------------------------------------------------------------------------------------------------

# use strict;
use warnings;
use Getopt::Long;
use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );
use Win32::OLE;
use Win32::OLE qw(in with); 
use Win32::OLE::Const 'Microsoft ActiveX Data Objects';
use Win32::File;
use Win32::FileOp;
use File::Path;
use File::DosGlob 'glob';
use File::Basename;
use MIME::Lite;
use Net::SMTP;
use Mega::Logger;
use Mega::PatchIni;
use Mega::Exploit;
use Cwd;

my $debug = 0;
my $verbosity = 2; # 0: silencieux, 1: suivi des 'grandes etapes'
                   # 2: suivi au niveau 'Component' progress, 3: suivi au niveau 'File'
                   # 4: encore plus de traces (a reserver au debug)

my $me = $0;
my $minime = basename $0;
$0 = $minime;
my $Logger = new Mega::Logger;




my $logfile = "";
if ( exists $ENV{'USERPROFILE'} ) {
    if ( ! -d $ENV{'USERPROFILE'} . "\\Logs" ) {
        mkdir($ENV{'USERPROFILE'} . "\\Logs" );
    }
    if ( -d $ENV{'USERPROFILE'} . "\\Logs" ) {
        $logfile = $ENV{'USERPROFILE'} . "/Logs/expmaster_buildmsi_$$.log";
    }
}
if ( $logfile eq "" ) {
    $logfile = $ENV{TEMP} . "/expmaster_buildmsi_$$.log";
}
$Logger->open($logfile);
$Logger->set_prefix('#date#');
$Logger->log(join (' ', "$0", @ARGV, "\n", "\n"));
$| = 1;


# Minimize the Perl's DOS window
# my ($DOShwnd, $DOShinstance) =Win32::GUI::GetPerlWindow();
# Win32::GUI::CloseWindow($DOShwnd);
#Win32::GUI::Hide($DOShwnd);

my $bCopie       = 0;
my $bFtp         = 0;
my $bLancement   = 0;
my $bCompression = 0;
my $PrivMaster   = "_Default";
my $just_test = 0;

my $File_Ini;
my $result = GetOptions ( 'ini=s' => \$File_Ini,
                          'test' => \$just_test,
                        );

my $Master    = shift;
$Master.="_2015";

my $Version   = shift;
my $Espace    = shift;
my $Mode      = shift;
$PrivMaster   = shift;
$bCopie       = shift;
$bLancement   = shift;
$bFtp         = shift;
my $FlagEndTrt = shift;

if($FlagEndTrt ne"")
{ 
  setEHComputerNameAsFlag($FlagEndTrt);
}




#-----------------------------------------------------------------------------------------------------
#  Bricolage de l'espace si pas INT ou TST (et toujours en minuscules)
#-----------------------------------------------------------------------------------------------------
$Espace = lc($Espace);
my $RealEspace = $Espace;
if ($Espace ne "int") {$Espace = "tst";}
#-----------------------------------------------------------------------------------------------------

$Logger->close();
my $newlogfile = $logfile;
$newlogfile =~ s/expmaster_buildmsi/$Version-$RealEspace-expmaster_buildmsi/;
rename($logfile, $newlogfile);
$Logger->open_append($newlogfile);
$Logger->set_prefix('#date#');
$Logger->log("Logfile renamed from $logfile to $newlogfile\n");

Flag_IncrementCounter($FlagEndTrt, $PrivMaster);
Flag_WriteFile($FlagEndTrt, "MainLog", $newlogfile);

my $EnvKey= $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/MEGA/InstallShieldX/PathVariables"} or $Logger->fail("impossible d'ouvrir la registry\n");


if ( ! defined $File_Ini ) {
    $File_Ini = "w:/tools/Versions.ini";
}
if ( ! -r $File_Ini ) {
    # Restore the window
    # Win32::GUI::OpenIcon($DOShwnd);
    $Logger->fail("Cannot read $File_Ini . Fatal ");
}

my @L_Versions = ();
@L_Versions = Read_Ini_Sections($File_Ini);
unless  ( grep { $Version } @L_Versions ) {
    # Restore the window
    # Win32::GUI::OpenIcon($DOShwnd);
    $Logger->log_print("$0: Parameter error: unknown version $Version in $File_Ini. Abort.\n");
    exit 1;
}

#-----------------------------------------------------------------------------------------------------
#  Lancement Master
#-----------------------------------------------------------------------------------------------------

#  Preparation des variables 

$Logger->log_print("Preparation des variables\n");

my $PathOrigine    = Read_Ini($File_Ini, "$Version","PathOrigine",""); # OK
my $PathDemo       = Read_Ini($File_Ini, "$Version","PathDemo","");    # OK
my $PathTarget     = Read_Ini($File_Ini, "$Version","PathTarget","");  # OK
# my $PathMaster     = Read_Ini($File_Ini, "$Version","PathMaster","");  # OK
my $PathMaster     = "W:\\temp\\install770\\master_test\\mega_msi_2015_default.int"; 

my $PathInstall    = Read_Ini($File_Ini, "$Version","PathInstall",""); # OK
my $VersionName    = Read_Ini($File_Ini, "$Version","VersionName",""); # OK
my $BuildIncrement = Read_Ini($File_Ini, "$Version","BuildIncrement",""); # OK
my $PathIntegr     = Read_Ini($File_Ini, "$Version","PathIntegr",""); # OK
my $PathIntegrUnc  = Read_Ini($File_Ini, "$Version","PathIntegrUnc",""); # OK
my $PathInstallUnc = Read_Ini($File_Ini, "$Version","PathInstallUnc",""); # OK
my $VersionMajor   = Read_Ini($File_Ini, "$Version","VersionMajor",""); # OK
my $VersionMega    = Read_Ini($File_Ini, "$Version","VersionMega",""); # OK
my $ProductName    = Read_Ini($File_Ini, "$Version","ProductName",""); # OK
my $ProductVersion = Read_Ini($File_Ini, "$Version","ProductVersion",""); # OK
my $UpgradeCode_msi = Read_Ini($File_Ini,"$Version","UpgradeCode_msi",""); # OK
my $ProductCode_msi = Read_Ini($File_Ini,"$Version","ProductCode_msi","");  # utilise aussi en left exp (_default+tst)
my $PathPrivilege  = Read_Ini($File_Ini, "$Version","PathPrivilege",""); # OK
my $PreviousMsi    = Read_Ini($File_Ini, "$Version","master_reference","");
my $MsiName        = Read_Ini($File_Ini, "$Version","MsiName","");

print "#XYU# ProductCode_msi=".$ProductCode_msi."\n";
my $PathMgr         =  "$PathDemo\\Mgr";
my $PathFournitures =  "$PathDemo";
if ($Espace eq "tst") {
  $PathFournitures = "$PathDemo.$Espace";
  $PathMgr         = "$PathDemo.$Espace\\Mgr";
  $VersionMega    = Read_Ini($File_Ini, "$Version","VersionMegaTst","");
  $ProductName    = Read_Ini($File_Ini, "$Version","ProductNameTst","");
  $ProductVersion = Read_Ini($File_Ini, "$Version","ProductVersionTst","");
  $ProductCode_msi= Read_Ini($File_Ini, "$Version","ProductCode_msiTst","");
}

if ($RealEspace ne $Espace) {
# On ne modifie pas $PathMgrIni volontairement !
  $PathMgr         = "$PathDemo.$RealEspace\\Mgr";
# On reste comme en INT
  $VersionMega    = Read_Ini($File_Ini, "$Version","VersionMega",""); # OK
  $ProductName    = Read_Ini($File_Ini, "$Version","ProductName",""); # OK
  $ProductVersion = Read_Ini($File_Ini, "$Version","ProductVersion",""); # OK
  $UpgradeCode_msi = Read_Ini($File_Ini,"$Version","UpgradeCode_msi",""); # OK
}

print "#XYU# ProductCode_msi=".$ProductCode_msi."\n";
my $PathOrigineVersion = "$PathOrigine\\code-$Version.$RealEspace";

my $Old1 = $EnvKey->{"/PATH_TO_CCMFILES"};
my $Old2 = $EnvKey->{"/PATH_TO_FOURNITURES"};
my $Old3 = $EnvKey->{"/PATH_TO_INSTALLCODE"};



$EnvKey->{"/PATH_TO_CCMFILES"}    = ["$PathOrigineVersion\\code", 'REG_SZ'];
$EnvKey->{"/PATH_TO_FOURNITURES"} = ["$PathFournitures", 'REG_SZ'];
$EnvKey->{"/PATH_TO_INSTALLCODE"} = ["$PathTarget", 'REG_SZ'];
$EnvKey->{"/VERSION"} = ["$Version", 'REG_SZ'];
$EnvKey->{"/ESPACE"} = ["$Espace", 'REG_SZ'];




my $PathSetup = "C:\\install770";  # OK


# my $PathInsX = $PathOrigineVersion."\\code\\insx\\$Master.ism"; # OK

my $PathInsX = $PathSetup."\\$Master.ism"; 

$sPath = "C:\\Program Files (x86)\\InstallShield\\2015 SAB\\Support\\0409";
unlink "$sPath\\IsMsiPkg.itp";
CopyEx("$sPath\\IsMsiPkgLarge.itp" => "$sPath\\IsMsiPkg.itp",FOF_FILESONLY|FOF_NOCONFIRMMKDIR);


if ($RealEspace eq "tst") {
    my $ole = Win32::OLE->new('WindowsInstaller.Installer');
    
   $BuildIncrement = (split /\./, $ole->FileVersion("$PathOrigineVersion\\code\\ExeRelease_Win32\\mg_stdl.dll", 0))[2];  
    # $ole->FileVersion(..., 0) renvoie du 7.2.721.1234
    if ($Version eq "740" and lc($PrivMaster) eq "commercial_cd" ) {
        unlink "$sPath\\IsMsiPkg.itp";
        CopyEx("$sPath\\IsMsiPkgNormal.itp" => "$sPath\\IsMsiPkg.itp",FOF_FILESONLY | FOF_NOCONFIRMATION | FOF_NOCONFIRMMKDIR);
    }
}

$Logger->log_print("
Mise a jour du Master
     Master         : $Master
     Mode           : $Mode
     VersionName    : $VersionName
     Version        : $Version
     Espace         : $Espace
     RealEspace     : $RealEspace
     BuildIncrement : $BuildIncrement
     PathMaster         : $PathMaster
     PathInstallShield  : $PathInsX
     PreviousMsi    : $PreviousMsi
");

if ( $just_test ) {
    $Logger->close();
    exit 0;
}

$Logger->log_print("
#-----------------------------------------------------------------------------------------------------
#  Copie des fichiers de licence
#-----------------------------------------------------------------------------------------------------
");

my $PathTargetLicense = "$PathTarget\\License";
if (chdir($PathTargetLicense)) {
    Mega_del_tree("$PathTargetLicense");
} else {
    mkpath("$PathTargetLicense");
}

my $Fic_Evl = "$PathPrivilege\\$PrivMaster\\*.evl";
my @lficevl = glob "$Fic_Evl";
if (scalar(@lficevl)) {
    $Logger->log_print("Copie des fichiers evl vers l'espace de master\n");
    CopyEx("$Fic_Evl" => "$PathTargetLicense",FOF_FILESONLY|FOF_NOCONFIRMMKDIR);
}
my $Fic_Edu = "$PathPrivilege\\$PrivMaster\\*.edu";
my @lficedu = glob "$Fic_Edu";
if (scalar(@lficedu)) {
    $Logger->log_print("Copie des fichiers edu vers l'espace de master\n");
    CopyEx("$Fic_Edu" => "$PathTargetLicense",FOF_FILESONLY|FOF_NOCONFIRMMKDIR);
}




#-----------------------------------------------------------------------------------------------------
#  Ouverture Projet InstallShield X
#-----------------------------------------------------------------------------------------------------

$Logger->log_print("\nPreparation du master\n");

my $IProject = Win32::OLE->new ('ISWiAuto22.ISWiProject');
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}

# Open the project specified at the command line
print "open Projet\n";
$IProject->OpenProject("$PathInsX");
print $PathInsX;
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}

$IProject->{'UseXMLProjectFormat'} = 0;
print "UseXMLProjectFormat = 0\n";
$IProject->SaveProject();
print "save Project\n";
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
$IProject->CloseProject();
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
  
$IProject->OpenProject("$PathInsX");

$Logger->log_print("\nImport de Mega.reg\n");

my $RegImp = $IProject->ISWiComponents()->Item("Mega_System");
my $bRegImp = $RegImp->ImportRegFile("$PathMgr\\mega.reg",'True');
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}

$Logger->log_print("\nParametrage du master\n");

my $PConfig = $IProject->ISWiProductConfigs()->Item("mega");
my $PcName = $PConfig->Name();
$PConfig->{'GeneratePackageCode'} = 1;
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}

my $ProductNameX = "$ProductName";
if ( defined  $ProductVersion and ($ProductVersion ne "")) {
    $ProductNameX = "$ProductName $ProductVersion";
}

$PConfig->{'ProductName'} = $ProductNameX;
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
if ( $Version > 720 ) {
    $PConfig->{'ProductVersion'} = "$VersionMajor." . substr($VersionName,1) . ".$BuildIncrement"; # ---> 7.20.2346
} else {
    $PConfig->{'ProductVersion'} = "$VersionMajor.$VersionName.$BuildIncrement";                   # ---> 7.720.2346
}
$Logger->log_print("Value ProductVersion generated = $VersionMajor." . substr($VersionName,1) . ".$BuildIncrement");
$Logger->log_print("ProductVersion entered = ".$PConfig->{'ProductVersion'}."\n");
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}

$PConfig->{'UpgradeCode'} = $UpgradeCode_msi;
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}

if ($RealEspace eq "tst") {
    if (lc($PrivMaster) eq "_default") {
        $PConfig->{'ProductCode'} = $IProject->GenerateGUID;
        if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
        $IProject->SaveProject();
        $ProductCode_msi   = $IProject->{'ProductCode'};    

        Write_Ini($File_Ini, "$Version","ProductCode_msi","$ProductCode_msi");
    } else {
        $PConfig->{'ProductCode'} = $ProductCode_msi;
        if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
    }
} else {
    $PConfig->{'ProductCode'} = $IProject->GenerateGUID;
    if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
}
# print "#XYU#final ProductCode_msi=".$ProductCode_msi."\n";

my $Release = lc($PrivMaster);
my $pRelease = $PConfig->ISWiReleases()->Item("$Release");
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
$pRelease->{'BuildLocation'} = "$PathMaster\\$Master$PrivMaster.$RealEspace\\$BuildIncrement";
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
if ($RealEspace eq "tst") {
    $pRelease->{'OptimizeSize'} = 0;
} else {
    $pRelease->{'OptimizeSize'} = 0;
}
$pRelease->{'DefaultLang'} = 1033;
if ( (defined $PreviousMsi) and ($PreviousMsi ne '') ) {
    $pRelease->{'PreviousPackage'} = $PreviousMsi;
    $Logger->log_print(" PreviousPackage set to: [$PreviousMsi] \n");
}

$Logger->log_print("Mise a jour des setup files\n");
# Mise a jour des setup files 
my $PathSetupFile = "$PathSetup\\$Master";
if (chdir($PathSetupFile)) {
    my $PathPrivilegeFile = "$PathPrivilege\\$PrivMaster";
    my $file1 = "MEGA Suite.bmp";
    my $file2 = "setup.bmp"; 
    my $Attributes;
    if (Win32::File::GetAttributes("$PathPrivilegeFile\\$file1", $Attributes)) {
        CopyEx("$PathPrivilegeFile\\$file1" => "$PathSetupFile\\$file2",FOF_FILESONLY | FOF_NOCONFIRMATION );
    }
}

$IProject->SaveProject();
my $PackageGUID   = $IProject->{'PackageCode'};    
Write_Ini($File_Ini, "$Version","PackageCode_msi","$PackageGUID");

my $PmasterW = "$PathMaster\\$Master$PrivMaster.$RealEspace\\$BuildIncrement\\mega\\$PrivMaster";
if (chdir("$PmasterW\\LogFiles")) {
    rmtree("$PmasterW\\LogFiles", {keep_root=>1});
    chdir("$PathMaster");
}
$Logger->log_print("Construction du master en cours: \n");
$pRelease->Build();
if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
$Logger->log_print("... construit\n");


#-----------------------------------------------------------
# Gestion des erreurs de generation du master
#-----------------------------------------------------------
my $sretError = -1;
my $sretWarning = -1;
if ( chdir "$PmasterW\\LogFiles" ) {
    my $logfile = (glob "*.txt")[0];
    if ( open my $hdl, "<", "$logfile" ) {
        my $file = (grep { /error\(s\), \d+ warning\(s\)/ } <$hdl>)[0];
        my ($err, $war);
        if ( $file ) {
            $file =~ /(\d+) error\(s\), (\d+) warning\(s\)/;
            ($err, $war) = ($1, $2);
        }
        unless ( defined $err )
        {
            $err = $pRelease->{'BuildErrorCount'};
            if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
        }
        $sretError = $err if ( defined $err );
        unless ( defined $war )
        {
            $war = $pRelease->{'BuildWarningCount'};
            if (Win32::OLE->LastError()!=0) {$Logger->log_print("Erreur OLE " . Win32::OLE->LastError() ."\n");}
        }
        $sretWarning = $war if ( defined $war );        
    }
    chdir("$PathMaster");
}
$Logger->log_print("    $sretError erreurs  (-1 signifie info non disponible)\n");
$Logger->log_print("    $sretWarning warnings (-1 signifie info non disponible)\n");

if ($RealEspace eq "tst") {
    if (lc($PrivMaster) eq "_default") {
        $ProductCode_msi   = $IProject->{'ProductCode'};    
        Write_Ini($File_Ini, "$Version","ProductCode_msi","$ProductCode_msi");
    }
}
if ( $sretError == 0 ) {
    $Logger->log_print("Nouvel MSI : $PmasterW\\DiskImages\\DISK1\\$MsiName.msi \n");
}


if (chdir($PmasterW)) {
    open my $fpipe, "-|", "attrib -r *.* /S /D";
    $Logger->log_print($_) while ( <$fpipe> );
    close ($fpipe);
    chdir("$PathMaster");
}

my $bError = 0;
if ($sretError >= 1) {
    if (chdir("$PmasterW\\LogFiles")) {
        my @files = glob "*.txt";
        my $FileLog = '';
        foreach my $file (@files) {
            if (!(-d $file)) {
                $FileLog = "$PmasterW\\LogFiles\\$file";
            }
        }
        Flag_WriteFile($FlagEndTrt, "ErrorLog", $FileLog);
        Send_mail_master($Version, $BuildIncrement, "$PmasterW\\DiskImages\\DISK1", $FileLog, $PrivMaster, $FlagEndTrt);
        $bError = 1;
        if (lc($PrivMaster) eq "_default") {CreatingStopFlag("$Version", "$RealEspace", "$0");}
    }
} 

if ($bCopie and !$bError){
    my $PathCpyIntegr = "$PathIntegr\\$ProductNameX ($RealEspace Build) $Master\\$VersionMega-$BuildIncrement\\$PrivMaster";
    my $PathIntegrUncV = "$PathIntegrUnc\\$ProductNameX ($RealEspace Build) $Master\\$VersionMega-$BuildIncrement\\$PrivMaster";

    if (chdir("$PathCpyIntegr")) {
        rmtree("$PathCpyIntegr", { keep_root => 1 });
    }

    $Logger->log_print("Copie du master $PathMaster\\$Master$PrivMaster.$RealEspace\\$BuildIncrement\\mega\\$PrivMaster\\DiskImages vers $PathCpyIntegr\n");
    my $PathOrigin = "$PathMaster\\$Master$PrivMaster.$RealEspace\\$BuildIncrement\\mega\\$PrivMaster\\DiskImages";
    UpdateDir ("$PathOrigin" => "$PathCpyIntegr");
    opendir($dirHandle, $PathOrigin."\\DISK1") or die "### ERROR ### Impossible d'ouvrir le répertoire '$PathOrigin.\\DISK1' : $!\n";
    foreach $strFileName (readdir($dirHandle)) {
      next if ($strFileName eq "." or $strFileName eq "..");
      next if (-e $PathCpyIntegr."\\DISK1\\".$strFileName) ;
      $Logger->log_print("    $strFileName : pb de copie\n");
      $bError = 0;  
    }
    closedir($dirHandle);
    undef $strFileName;
    undef $dirHandle;

    my $FicInstall = "$PathIntegr\\$PrivMaster-$VersionMega-$RealEspace.txt";
    open(Install, ">", "$FicInstall") or $Logger->fail("Impossible d'ouvrir le fichier: $!");
    print Install "$PathCpyIntegr\n";
    close Install;
    
    Flag_WriteFile($FlagEndTrt, "InstallLog", $FicInstall);


    if ($bLancement){
        
        my $VersionInstall = $VersionMega;
        if ( $VersionInstall == 0) {
            $VersionInstall = $VersionName;
        }
        my $TEMP = $ENV{"temp"};            
        my $SetupLog = "$TEMP\\setup$Version$RealEspace.log";
        
        my $InstallPath     = "r:\\DailyBuildInstalled\\$ProductNameX ($RealEspace Build) $Master\\$VersionMega-$BuildIncrement.Us";
        my $PathInstallUncV = "$PathInstallUnc\\$ProductNameX ($RealEspace Build) $Master\\$VersionMega-$BuildIncrement.Us";

        my $FicSetup = "$PathIntegr\\$PrivMaster-$VersionMega-$RealEspace.ini";
        if (-e $FicSetup) 
        {
            unlink($FicSetup); 
        }
        
        Write_Ini($FicSetup, "$PrivMaster", "MsiName", "$MsiName.msi");
        Write_Ini($FicSetup, "$PrivMaster", "BuildNum", "$BuildIncrement");
        Write_Ini($FicSetup, "$PrivMaster", "Master", "$Master");
        Write_Ini($FicSetup, "$PrivMaster", "InstallSource", "$PathIntegrUncV\\Disk1");
        Write_Ini($FicSetup, "$PrivMaster", "InstallDest","$PathInstallUncV");
    }
}
if ($bError){
  Flag_WriteStatus("Ko", $FlagEndTrt);
} else {
  Flag_WriteStatus("Ok", $FlagEndTrt);
}

$EnvKey->{"/PATH_TO_CCMFILES"}    = ["$Old1", 'REG_SZ'];
$EnvKey->{"/PATH_TO_FOURNITURES"} = ["$Old2", 'REG_SZ'];
$EnvKey->{"/PATH_TO_INSTALLCODE"} = ["$Old3", 'REG_SZ'];


$Logger->log_print("That's all folks.\n");
$Logger->close();

exit 0;

#----------------------------------------------------
# Envoi du compte-rendu de masterisation
#----------------------------------------------------
sub Send_mail_master {
    my $mVersion   = shift;
    my $mIncrement = shift;
    my $mMaster    = shift;
    my $mFileLog   = shift;
    my $PrivMaster = shift;
    my $FlagEndTrt = shift;

    $Logger->log_print("Envoi du compte-rendu d'erreur de preparation du master $PrivMaster...\n");

    my $texte  = "";
    my $addrto = "exploitation";
    my $sujet = "";
    my $attach = "";

    $sujet = "Le master $PrivMaster de la version $RealEspace $mVersion Build $mIncrement a généré des erreurs";
    $texte  = " Master $mMaster";
    
    Flag_WriteStatus("Ko", $FlagEndTrt);
    
    $attach = "$mFileLog";
    my $filename = basename($attach);

    my $Message = new MIME::Lite 
    From =>'exploitation@mega.com', 
    To =>'exploitation@mega.com,hgilbert@mega.com,xyu@mega.com', 
    Subject =>$sujet,
    Type =>'multipart/mixed'; 
    # Ajoutez le message (texte ou html)
    attach $Message 
        Type =>'TEXT', Data =>"$texte";

    # Ajoutez un document log
    attach $Message 
        Type =>'application/log',Path =>$attach,Filename =>$filename; 

    $user="exp2";
    $pass="exp06";
    MIME::Lite->send('smtp', 'exa.fr.mega.com', AuthUser=>$user, AuthPass=>$pass);
   
    $Message->send('smtp', 'exa.fr.mega.com', Timeout=>60, Hello=>'mega.com');
}

__END__

