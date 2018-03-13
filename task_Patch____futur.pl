#=====================================================================================================
#							INCLUDED MODULES
#=====================================================================================================

use Win32::GUI();
use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::FileOp;
use Date::Calc qw(:all);
use Mega::Exploit;
use Mega::Synergy::Sessions;

####################################################
# préparation des variables.
####################################################


my $version = 	$ARGV[0];
my $esapce = 	$ARGV[1];
my $tasks_string = $ARGV[2]; # la list doit être séparé par ";"
my $output_mode = $ARGV[3]; # output mode = "HF" or "VM" or "QA" or "NONE"

##################################################################################
# copie coller d'un autre script: exp_atf.pl
#
# check session ccm, si ça existe, l'utilise, sinon en cree une autre.
##################################################################################
print "#############  preparation d'une session synergy ##########\n";

	
$ccm_db = "modeling";
$ccm_interface = "cli";

set_synergy_env($ccm_db,$ccm_interface);
set_exploit_env($ccm_db);

print "\nSearching for opened sessions of IBM Rational Synergy on database $ccm_db...";
my $chksession = ccm_check_session($ccm_db,$ccm_interface);

my $bOkSession;
my $NewCcmAddr;

if( ! $chksession ) {

	print "\nNo session opened on $ccm_db database\n";
	print "\nOpening new session...";
	$NewCcmAddr = ccm_start_session($ccm_db,$ccm_interface);
	if($NewCcmAddr){
		print "\nOpened\n";
	} else {
		print "\nError appeared while opening a new session. Please check IBM Rational Synergy log files or contact build management team.\n";
		exit 0;
	}
} else {
	print "\nOne session found on $ccm_db database in $ccm_interface mode\n";
	print "\nConnecting to this session...";
	$bOkSession = ccm_use_session($chksession);
	if($bOkSession){
		print "\nConnected\n";
	} else {
		print "\nError appeared while connecting to an opened session. Please check IBM Rational Synergy log files or contact build management team.\n";
		exit 0;
	}
}# fin de copie coller d'un autre script: exp_atf.pl
print "##############  fin de la preparation Session Synergy ###############\n";


####################################################
# controler si toutes les tâches sont completées.
####################################################
print "Analyse la liste des tâches, faut que tout les tâches dans la liste soient completée, sinon le program s'abondone.\n";
@task_list = split(/;/, $tasks_string);
foreach $task (@task_list) {
	my $task_status = `ccm task /show info /format %status $task`;
	chomp($task_status);
	if(lc($task_status) ne "completed"){
		print $task." n'est pas une tâche completée, Abandonne...\n";
		ccm_stop_session();
		exit 1;
	}
}
print "Analyse OK\n";


#####################################################
# on commence par l'envoi du mail d'information.
# comme quoi on va arrêter la VM pour une patch
#####################################################
my $versions_ini = "w:\\tools\\versions.ini";
my $trt_ini = "w:\\tools\\trt.ini";
my $vm_suffix = Read_Ini($trt_ini, "$version.$espace","lastvm","");
my $vm_name = "vp-".$vm_suffix;

print "Le programe va remontée les Tâches: $tasks_string en version:$version espace:$espace et builder les DLL/JAR correspend puis patcher la VM $vm_name\n";

if($simul eq 0){
	if($patch_VM eq 1){
		# envoyer un mail /*on va arrêter la VM*/	
	}
	#fin d'envoi du mail.
}

#####################################################################################################
# prendre les sources à partir des tasks, ainsi que les noms des projet à rebuilder
#####################################################################################################

print "Cherche info tâches...\n";
my @projet_list_code=();
my @projet_list_java=();
foreach $task (@task_list){
	
	my @task_source = `ccm task /show obj $task /f %name;%project;%type;;%version`;
	foreach $Line (@task_source)
	{
		# print $Line;
		chomp($Line);
		# if($Line =~/<void>$/) {
			my @array = split(/;/, $Line);
			print $Line."\n";
			#historiquement y a un projet s'appelle 'i' laissé dans la base synergy, peut-être pas seulement 'i', à devouvrir.
			
			if($array[2] eq "java"){
				if(!grep(/$array[1]/, @projet_list_java)){ 
					push(@projet_list_java, $array[1]);
				}
				
			}else{
				
				if($array[1] eq "i"){
					$array[1] = "code";
				}
				if($array[1] ne "code"){
				
					if(!grep (/$array[1]/, @projet_list_code)){ 
						push(@projet_list_code, $array[1]);
					}
				}
			}
		# }
	}
}

##############################################################################
# calcul l'ordre de build des projets. que pour les projet CPP, pour JAVA on s'en fou.
##############################################################################

# importer le fichier build_c_index.txt dans une HASH

my %hash;
open (FILE, 'C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\build_c_index.txt');
while (<FILE>)
{
   chomp;
   my ($key, $val) = split /:/;
   $hash{$key} = $val;
}
my %hash_final;
foreach $projet (@projet_list_code){
	if(exists $hash{$projet}){
		$hash_final{$hash{$projet}} = $projet;
	}
}
my @projet_list_code=();
foreach $k (sort keys %hash_final){
	push(@projet_list_code, $hash_final{$k});
}
push(@projet_list_code, "stdl");

print "les Projets CCM à rebuilder:\n";
print "les Projets CCM à rebuilder:\n";
print "Pour Visual:\n";
foreach $p (@projet_list_code){
	print $p."\n";
}

print "Pour Java:\n";
foreach $p (@projet_list_java){
	print $p."\n";
}

######################################################## 
#  remonter les tâches en question dans le folder ciblé.
######################################################## 


print "Remonter les tâches dans folder $version $espace\n";

$espace_min = lc($espace);
my $folder_target = Read_Ini($versions_ini, "$version","folder_$espace_min","");

foreach $task (@task_list){
	
        my $stask = "task$task";
        my $ret ="";
        $PgmVar = "ccm query /t task /name $stask \"is_task_in_folder_of('probtrac/folder/$folder_target/1')\"";
        print "$PgmVar\n";
		($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
        $ret = <PIPE>;
        close(PIPE);

		 if ($ret eq "") {
			    $PgmVar = "ccm folder /m /at $task $Folder";
                
				if($simul eq 0){
					print "$PgmVar\n";
					($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
					while (defined($line = <PIPE>))
					{
						print "$line";
					}
					close(PIPE);		
				}		
		 }else{
			print "La tâche $task existe déjà dans le folder  $Folder\n";
		 }
}



######################################################## 
#  Build
######################################################## 
# commence par CPP
# Commence par le repertoire inc qui se trouve dans projet CODE, c'est une répertoire mais pas un projet, on le traitera différement

print "Build les projets CCM\n";

if(scalar(@projet_list_code)>0){
	print "Pour projet visual on commence par le repertoire code\\inc \n";
	my $reconf_inc = "ccm reconf \"X:\\wa\\code-$version.$espace\\code\\inc";
	print $reconf_inc;
	if($simul eq 0){
		($pid = open(PIPE, "ccm reconf /p $reconf_inc /r |")) or die "Impossible d'exécuter : $!\n";
		while (defined($line = <PIPE>))
		{
			print "$line";
		}
		close(PIPE);
	}
	# boucle de projets list pour les projet à reconfigurer.
	
	
	foreach $projet (@projet_list_code){
		# parametre: expcpblm.pl $espace $version $mode $compile $reconf $projet";
		$PgmVar = "w:\\tools\\expcpblm.pl $espace $version release 1 1 $projet";
		print $PgmVar; 
		if($simul eq 0){
			($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
			while (defined($line = <PIPE>))
			{
				print "$line";
			}
			close(PIPE);
		}
	}
}
# boucle de projets list pour les projet à reconfigurer.
if(scalar(@projet_list_java) > 0){
	foreach $projet (@projet_list_java){
		$PgmVar = "w:\\tools\\expdev_java_proj.pl $espace $version release 1 mjava $projet";
		print $PgmVar;
		if($simul eq 0){
			($pid = open(PIPE, "$PgmVar |")) or die "Impossible d'exécuter : $!\n";
			while (defined($line = <PIPE>))
			{
				print "$line";
			}
			close(PIPE);
		}
	}
}

# fermer la session CCM
print "Fermer la session CCM\n";
ccm_stop_session();

################################
#  recupérer les fichier buildé 
################################

print "Récuperation des fichiers buildé.\n";

# CPP
my $dir_root = "X:\\wa\\code-$version.$espace\\code";
my $dir_exerelease="";

if($version <= 725 ){
	$dir_exerelease = $dir_root."\\exerelease";
}else{
	$dir_exerelease = $dir_root."\\ExeRelease_Win32";
}

my @file_built = ();
foreach $projet (@projet_list_code){
	my $file_name_complet = $dir_exerelease."\\mg_$projet.dll";
	print $file_name_complet."\n";
	push(@file_built, $file_name_complet);
}

# JAVA
$dir_exerelease = "X:\\wa\\mjava-$version.$espace\\mjava\\exerelease";
foreach $projet (@projet_list_java){
	my $file_name_complet = $dir_exerelease."\\mj_$projet.jar";
	print $file_name_complet."\n";
	push(@file_built, $file_name_complet);
}

if($patch_VM eq 1){

print "-------- on a choisi de patcher la VM avec les DLL/jars rebuildé ------------";

# stopVMParis
		print "Génération de fichier RDP pour StopVM\n";
		my $rdpTemplate = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\RemoteTemplate.rdp";
		my $rdpStop = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\ExpStopVM.rdp";
		my $stopCommand = "ExpStopVM";
		
		open(FILE, "<$rdpTemplate") || die "File not found";
		my @lines = <FILE>;
		close(FILE);

#######
$vm_name = "vp-dl-xyu";
#######

		my @newlines;
		foreach(@lines) {
		   $_ =~ s/COMMANDENAME/ExpStopVM/g;
		   $_ =~ s/MACHINENAME/$vm_name/g;
		   push(@newlines,$_);
		}

		open(FILE, ">$rdpStop") || die "File not found";
		print FILE @newlines;
		close(FILE);
		my $commandRemote = "start /wait mstsc $rdpStop";
		system($commandRemote);
		unlink $rdpStop;


# CopieFileVM 
# &&&&& 
# CreateZip 
		#copie
		$dir_dest = "\\vm_name\C$\Program Files (x86)\MEGA\MEGA HOPEX V1R2\System";		
		#zip
		my $patch_dir = "w:\\temp\\QuickPatch";
		if(! -d $patch_dir){
			mkdir($patch_dir);
		}
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900;
		$mon += 1;
		my $zip_file = $patch_dir."\\QuickPatch_$version_$espace_$mday$mon_$hour$min.zip";	
		if(-f $zip_file){
			unlink $zip_file;
		}
		
		my $zip_instance = Archive::Zip->new();
		foreach $file (@file_built) {
			CopyEx("$file\\*" => "$dir_dest",FOF_NOCONFIRMMKDIR|FOF_NOCONFIRMATION);
			my $file_added = $zip_instance->addFile($file);
		}
		
		unless ( $zip_instance->writeToFileNamed($zip_file) == AZ_OK ) {
		   print "Error: not able to write into the zip file: $zip_file\n";
		}
		


# RestartVMParis
		print "Génération de fichier RDP pour RestartVM\n";
		$rdpStart = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\ExpStopVM.rdp";
		$restartCommand = "ExpRestartVM";
		
		open(FILE, "<$rdpTemplate") || die "File not found";
		my @lines = <FILE>;
		close(FILE);


		@newlines = ();
		foreach(@lines) {
		   $_ =~ s/COMMANDENAME/ExpRestartVM/g;
		   $_ =~ s/MACHINENAME/$vm_name/g;
		   push(@newlines,$_);
		}

		open(FILE, ">$rdpStart") || die "File not found";
		print FILE @newlines;
		close(FILE);
		my $commandRemote = "start /wait mstsc $rdpStart";
		system($commandRemote);
		unlink $rdpStart;

		# EnvoiMailXYU
		my $texte = "";
		$texte .= 
		
		my $Message = new MIME::Lite 
		From =>'xyu@mega.com', 
		To =>'xyu@mega.com', 
		Subject =>'QuickPatch_$version_$espace',
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




