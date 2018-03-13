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
# use warnings;
use Getopt::Long;
use Win32::TieRegistry( Delimiter=>"/", ArrayValues=>0 );
# use Win32::OLE;
use Win32::OLE qw(in with); 
use Win32::OLE::Const 'Microsoft ActiveX Data Objects';
use Win32::File;
use Win32::FileOp;
use File::Path;
use File::DosGlob 'glob';
use File::Basename;
use MIME::Lite;

# use Mega::Logger;
use Mega::PatchIni;
use Mega::Exploit;
use Cwd;



my $version    = $ARGV[0];
my $File_Ini  = "W:\\tools\\buildmsp.ini";
my $file_log = $ENV{'USERPROFILE'}."\\exp_MSP_build.log";
open(LOG,">$file_log") or die "Impossible to open the log file :$!";


my $dir_patch = Read_Ini($File_Ini, "$version","path_patch","");
my $file_patch = Read_Ini($File_Ini, "$version","file_patch","");
my $PathInsX = "$dir_patch\\$file_patch.ism";
my $patch_origine = Read_Ini($File_Ini, "$version","last_patch","");
my $patch_target = Read_Ini($File_Ini, "$version","next_patch","");



print LOG "\nProcessus demarré,Projet ISM: \n\n \t $PathInsX \n\nCe processus buildra le MSP de $patch_origine à $patch_target \n";
print "\nProcessus demarré,Projet ISM: \n\n \t $PathInsX \n\nCe processus buildra le MSP de $patch_origine à $patch_target \n";


#-----------------------------------------------------------------------------------------------------
#  check the existance of the last CD_Commercial
#-----------------------------------------------------------------------------------------------------
my $version_ini = "W:\\tools\\versions.ini";
my $bIncrmt = Read_Ini($version_ini, "$version","buildincrement","");
my $IS_type =  Read_Ini($File_Ini, "$version","installshield_type","");
my $dir_CD_Commercial = "w:\\$version\\Master\\$IS_type"."Commercial_CD.tst\\$bIncrmt\\mega\\commercial_cd\\DiskImages\\DISK1";
if(! -d $dir_CD_Commercial){
	print LOG "\nLe master CD_Commercial du jour ($bIncrmt) n'existe pas, on va prendre le dernière disponible.\n\n";
	print "\nLe master CD_Commercial du jour ($bIncrmt) n'existe pas, on va prendre le dernière disponible.\n\n";
	
	my $root_dir_comm = "w:\\$version\\Master\\$IS_type"."Commercial_CD.tst";
	if(chdir($root_dir_comm)){
		opendir my($dir), $root_dir_comm or die "Couldn't open dir '$dirname': $!";
		my @files = readdir $dir;
		closedir $dir;
		my $last_CD_comm = $files[scalar(@files)-1];
		$dir_CD_Commercial = $root_dir_comm."\\$last_CD_comm\\mega\\commercial_cd\\DiskImages\\DISK1";
		print LOG "le numéro de build ciblé sera $last_CD_comm et le fichier MSI est: \n\n \t $dir_CD_Commercial\n\n";
		print "le numéro de build ciblé sera $last_CD_comm et le fichier MSI est: \n\n \t $dir_CD_Commercial\n\n";
	}
}else{
	print LOG "le numéro de build ciblé sera $last_CD_comm et le fichier MSI est: \n\n \t $dir_CD_Commercial\n\n";
	print "le numéro de build ciblé sera $last_CD_comm et le fichier MSI est: \n\n \t $dir_CD_Commercial\n\n";
}

#-----------------------------------------------------------------------------------------------------
#  check and make the administrative installation.
#-----------------------------------------------------------------------------------------------------
my $dir_install_admin = $dir_patch."\\".$patch_target;

print "On cherche si la dernière installation administrative existe, si c'est le cas on va la supprimer et refaire.\n";
print LOG "On cherche si la dernière installation administrative existe, si c'est le cas on va la supprimer et refaire.\n";

if(chdir($dir_install_admin)){
	print "repertoire $dir_install_admin existe, on va la vider...\n";
	print LOG "repertoire $dir_install_admin existe, on va la vider...\n";
	#debug Mega_del_tree($dir_install_admin);
	
}else{
	print "Repertoire $dir_install_admin n'existe pas, on va la creer...\n";
	print LOG "Repertoire $dir_install_admin n'existe pas, on va la creer...\n";
	mkdir($dir_install_admin);
}

my $msi_name = Read_Ini($File_Ini, "$version","msi_name","");
my $msi_file = $dir_CD_Commercial."\\$msi_name";
my $dest_install_admin = Read_Ini($File_Ini, "$version","next_install_admin","");
#debug my $command_I_A = "msiexec /a \"$msi_file\" /passive TARGETDIR=\"".$dir_install_admin."\\$dest_install_admin\" /lv ".$ENV{'USERPROFILE'}."\\install_admin_log.log";
my $command_I_A = "echo msiexec /a \"$msi_file\" /passive TARGETDIR=\"".$dir_install_admin."\\$dest_install_admin\" /lv ".$ENV{'USERPROFILE'}."\\install_admin_log.log";


print "On va refaire l'installation administrative de $patch_target \nLa commande d'Install Administrative sera: \n\n\t".$command_I_A."\n\n";
print LOG "On va refaire l'installation administrative de $patch_target \nLa commande d'Install Administrative sera: \n\n\t".$command_I_A."\n\n";

if(system($command_I_A)==0){
	print "Installation Administrative OK.";
}else{
	print "\n\n#KO: Installation Administrative KO. Aborting...\nPour comprendre le problème, le log : ".$ENV{'USERPROFILE'}."\\install_admin_log.log";
}

#-----------------------------------------------------------------------------------------------------
#  arbitrage avant de lancer 
#-----------------------------------------------------------------------------------------------------
# suppresion et recopie de dossier Demostration de CP precedente.
my $product_name = Read_Ini($File_Ini, "$version","product_name","");
my $origine_install_admin = Read_Ini($File_Ini, "$version","last_install_admin","");
$dir_demo_target = $dir_install_admin."\\".$dest_install_admin."\\program files\\MEGA\\$product_name\\EnvDir";
$dir_demo_origine = $dir_install_admin."\\".$origine_install_admin."\\program files\\MEGA\\$product_name\\EnvDir";

if(chdir($dir_demo_target)){
	print "On va supprimer le dossier Demostration dans $dir_demo_target\n";
	print LOG "On va supprimer le dossier Demostration dans $dir_demo_target\n";
	Mega_del_tree($dir_demo_target);
}

print "On va copier le dossier Demostration de CP precedent.\n";
print LOG "On va copier le dossier Demostration de CP precedent.\n";
CopyEx("$dir_demo_origine\\*" => "$dir_demo_target",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);


#-----------------------------------------------------------------------------------------------------
#  Ouverture Projet InstallShield X
#-----------------------------------------------------------------------------------------------------
my $IProject = Win32::OLE->new ('ISWiAuto18.ISWiProject');
my $patch_configuration = $product_name." ".$patch_target;

if (Win32::OLE->LastError()!=0) {print "Erreur OLE " . Win32::OLE->LastError() ."\n";}

# Open the project specified at the command line
print "open Projet\n";
print LOG "open Projet\n";
$IProject->OpenProject("$PathInsX");
print $PathInsX."\n";
print LOG $PathInsX."\n";
if (Win32::OLE->LastError()!=0) { print "Erreur OLE " . Win32::OLE->LastError() ."\n";}


#debug $IProject->BuildPatchConfiguration($patch_configuration);
print "Build.";
print LOG "Build.";


$IProject->CloseProject();
if (Win32::OLE->LastError()!=0) { print "Erreur OLE " . Win32::OLE->LastError() ."\n" ;}

print "ficheir log dispo: $file_log";
print LOG "ficheir log dispo: $file_log";









  