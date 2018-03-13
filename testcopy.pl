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

$PathOrigin = "W:\\750\\Master\\mega_msi_2012_default.int\\4317\\mega\\_default\\DiskImages";
# $PathIntegrUncV = "R:\\DailyBuild\\Mega Modeling\\MEGA HOPEX V1R2 (750) (int Build) mega_msi_2012\\750-4317\\_default\\DISK1";


    my $PathCpyIntegr = "R:\\DailyBuild\\Mega Modeling\\MEGA HOPEX V1R2 (750) (int Build) mega_msi_2012\\750-4317\\_default";
    # my $PathIntegrUncV = "$PathIntegrUnc\\$ProductNameX ($RealEspace Build) $Master\\$VersionMega-$BuildIncrement\\$PrivMaster";

    if (chdir("$PathCpyIntegr")) {
        rmtree("$PathCpyIntegr", { keep_root => 1 });
    }

    # my $PathOrigin = "$PathMaster\\$Master$PrivMaster.$RealEspace\\$BuildIncrement\\mega\\$PrivMaster\\DiskImages";
    # $Logger->log_print("Copie du master $PathOrigin vers $PathCpyIntegr\n");
	print "Copie du master $PathOrigin vers $PathCpyIntegr\n";
	
    UpdateDir ("$PathOrigin" => "$PathCpyIntegr");
    opendir($dirHandle, $PathOrigin."\\DISK1") or die "### ERROR ### Impossible d'ouvrir le répertoire '$PathOrigin.\\DISK1' : $!\n";
    @file_list = readdir($dirHandle);
	close($dirHandle);
	foreach $strFileName (@file_list) {
      if ($strFileName eq "." or $strFileName eq ".."){
		next;
	}	  
    if (-e $PathCpyIntegr."\\DISK1\\".$strFileName){
		next;
	} 
      # $Logger->log_print("    $strFileName : pb de copie, à Ratraper\n");
	  print "    $strFileName : pb de copie, à Ratraper\n";
	  CopyEx("$PathOrigin\\DISK1\\$strFileName" => "$PathCpyIntegr\\DISK1\\$strFileName",FOF_FILESONLY | FOF_NOCONFIRMATION );
      $bError = 0;  
    }


