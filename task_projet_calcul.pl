



use Win32::TieRegistry( Delimiter=>"#", ArrayValues=>0 );
use Win32::FileOp;
use Date::Calc qw(:all);
use Mega::Exploit;
use Mega::Synergy::Sessions;




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

# Préparation de task liste
my $file_input = "C:\\Users\\xyu\\Desktop\\Scriptes\\pl\\task_list.txt";

my @task_list=();
open (FILE, $file_input);
foreach $line (<FILE>)  {   
    
    my @line_array = split(/;/,$line);
	foreach $tache (@line_array){
		push(@task_list,$tache);
	}
}





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
				# if($array[1] eq "gbmm" || $array[0] =~ "Task"){ 
						
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
print "Pour Visual:\n";
foreach $p (@projet_list_code){
	print $p."\n";
}

print "Pour Java:\n";
foreach $p (@projet_list_java){
	print $p."\n";
}

# fermer la session CCM
print "Fermer la session CCM\n";
ccm_stop_session();
